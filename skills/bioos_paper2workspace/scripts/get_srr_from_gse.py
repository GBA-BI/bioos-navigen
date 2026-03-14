import csv
import io
import json
import random
import re
import time
from typing import List, Dict, Any, Optional, Set

import requests
from requests.adapters import HTTPAdapter
from urllib3.util.retry import Retry


EUTILS_BASE = "https://eutils.ncbi.nlm.nih.gov/entrez/eutils"
GEO_ACC_URL = "https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi"


class NCBIClient:
    def __init__(
        self,
        email: Optional[str] = None,
        api_key: Optional[str] = None,
        tool: str = "gse_to_sample_srr",
        timeout: int = 60,
        sleep_seconds: float = 0.8,
        max_retries: int = 5,
    ):
        self.email = email
        self.api_key = api_key
        self.tool = tool
        self.timeout = timeout
        self.sleep_seconds = sleep_seconds
        self.max_retries = max_retries

        self.session = requests.Session()
        self.session.headers.update(
            {
                "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36",
                "Accept": "*/*",
                "Accept-Encoding": "gzip, deflate",
                "Connection": "close",
            }
        )

        retry = Retry(
            total=max_retries,
            connect=max_retries,
            read=max_retries,
            status=max_retries,
            backoff_factor=1.5,
            status_forcelist=[429, 500, 502, 503, 504],
            allowed_methods=["GET"],
            raise_on_status=False,
        )

        adapter = HTTPAdapter(max_retries=retry, pool_connections=10, pool_maxsize=10)
        self.session.mount("https://", adapter)
        self.session.mount("http://", adapter)

    def _params(self, extra: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
        params = {"tool": self.tool}
        if self.email:
            params["email"] = self.email
        if self.api_key:
            params["api_key"] = self.api_key
        if extra:
            params.update(extra)
        return params

    def get_text(self, url: str, params: Optional[Dict[str, Any]] = None) -> str:
        last_err = None

        for attempt in range(1, self.max_retries + 2):
            try:
                # 基础限速 + 少量抖动
                time.sleep(self.sleep_seconds + random.uniform(0, 0.4))

                r = self.session.get(
                    url,
                    params=self._params(params),
                    timeout=(10, self.timeout),   # connect timeout, read timeout
                )
                r.raise_for_status()
                return r.text

            except requests.exceptions.RequestException as e:
                last_err = e
                if attempt > self.max_retries:
                    break

                wait_s = min(2 ** attempt, 20) + random.uniform(0, 0.5)
                print(
                    f"[WARN] Request failed (attempt {attempt}/{self.max_retries + 1}) "
                    f"url={url} params={self._params(params)} err={e}. "
                    f"Retrying in {wait_s:.1f}s..."
                )
                time.sleep(wait_s)

        raise RuntimeError(
            f"Failed to fetch after {self.max_retries + 1} attempts: "
            f"url={url}, params={self._params(params)}, last_error={last_err}"
        )


def normalize_gse(gse_id: str) -> str:
    gse = re.sub(r"\s+", "", gse_id).upper()
    if not re.fullmatch(r"GSE\d+", gse):
        raise ValueError(f"Invalid GSE accession: {gse_id}")
    return gse


def unique_preserve_order(items: List[str]) -> List[str]:
    seen: Set[str] = set()
    out: List[str] = []
    for x in items:
        if x not in seen:
            seen.add(x)
            out.append(x)
    return out


def parse_gsm_ids_from_gse_html(html: str) -> List[str]:
    gsm_ids = re.findall(r"\b(GSM\d+)\b", html, flags=re.IGNORECASE)
    return unique_preserve_order([x.upper() for x in gsm_ids])


def parse_sra_accessions_from_gsm_html(html: str) -> Dict[str, List[str]]:
    srx_ids = re.findall(r"\b(SRX\d+)\b", html, flags=re.IGNORECASE)
    srr_ids = re.findall(r"\b(SRR\d+)\b", html, flags=re.IGNORECASE)
    return {
        "srx_ids": unique_preserve_order([x.upper() for x in srx_ids]),
        "srr_ids": unique_preserve_order([x.upper() for x in srr_ids]),
    }


def efetch_runinfo_by_accessions(client: NCBIClient, accessions: List[str]) -> List[Dict[str, Any]]:
    if not accessions:
        return []

    rows: List[Dict[str, Any]] = []
    chunk_size = 50  # 再保守一点

    for i in range(0, len(accessions), chunk_size):
        chunk = accessions[i:i + chunk_size]
        text = client.get_text(
            f"{EUTILS_BASE}/efetch.fcgi",
            params={
                "db": "sra",
                "id": ",".join(chunk),
                "rettype": "runinfo",
                "retmode": "text",
            },
        ).strip()

        if not text:
            continue

        reader = csv.DictReader(io.StringIO(text))
        for row in reader:
            rows.append(dict(row))

    return rows


def gse_to_sample_srr(
    gse_id: str,
    email: Optional[str] = None,
    api_key: Optional[str] = None,
) -> Dict[str, List[str]]:
    client = NCBIClient(email=email, api_key=api_key)
    gse = normalize_gse(gse_id)

    # 1) GSE -> GSM
    gse_html = client.get_text(GEO_ACC_URL, params={"acc": gse})
    gsm_ids = parse_gsm_ids_from_gse_html(gse_html)

    # 2) GSM -> SRX / direct SRR
    sample_to_srx: Dict[str, List[str]] = {}
    sample_to_srr_direct: Dict[str, List[str]] = {}

    for gsm in gsm_ids:
        gsm_html = client.get_text(GEO_ACC_URL, params={"acc": gsm})
        sra_accs = parse_sra_accessions_from_gsm_html(gsm_html)
        sample_to_srx[gsm] = sra_accs["srx_ids"]
        sample_to_srr_direct[gsm] = sra_accs["srr_ids"]

    all_srx = unique_preserve_order(
        [srx for gsm in gsm_ids for srx in sample_to_srx.get(gsm, [])]
    )

    # 3) SRX -> RunInfo -> SRR
    runinfo_rows = efetch_runinfo_by_accessions(client, all_srx)

    exp_to_runs: Dict[str, List[str]] = {}
    for row in runinfo_rows:
        exp = (row.get("Experiment") or "").strip().upper()
        run = (row.get("Run") or "").strip().upper()
        if exp.startswith("SRX") and run.startswith("SRR"):
            exp_to_runs.setdefault(exp, [])
            if run not in exp_to_runs[exp]:
                exp_to_runs[exp].append(run)

    # 4) GSM -> SRR
    sample_to_srr: Dict[str, List[str]] = {}
    for gsm in gsm_ids:
        runs: List[str] = []
        for srx in sample_to_srx.get(gsm, []):
            runs.extend(exp_to_runs.get(srx, []))
        runs.extend(sample_to_srr_direct.get(gsm, []))
        runs = unique_preserve_order(runs)
        if runs:
            sample_to_srr[gsm] = runs

    return sample_to_srr

def flatten_sample_to_srr(sample_to_srr: Dict[str, List[str]]) -> List[str]:
    srr_list: List[str] = []
    seen: Set[str] = set()

    for runs in sample_to_srr.values():
        for srr in runs:
            if srr not in seen:
                seen.add(srr)
                srr_list.append(srr)

    return srr_list


if __name__ == "__main__":
    import sys

    if len(sys.argv) < 2:
        print("Usage: python get_srr_from_gse.py GSE150728")
        sys.exit(1)

    sample_to_srr = gse_to_sample_srr(sys.argv[1])
    srr_list = flatten_sample_to_srr(sample_to_srr)

    print(json.dumps({"srr_list": srr_list}, indent=2, ensure_ascii=False))