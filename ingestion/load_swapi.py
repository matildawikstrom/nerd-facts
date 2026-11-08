"""Extract & load: download raw data from swapi.dev into data/raw/swapi/<endpoint>.json.

This script only extracts and lands the data. No cleaning happens here; all
transformation is done in dbt (transform/), where it is tested and documented.

Run from the repo root:
    uv run python ingestion/load_swapi.py
"""

import json
from datetime import datetime, timezone
from pathlib import Path

import requests

BASE_URL = "https://swapi.dev/api"
ENDPOINTS = ["people", "films", "planets", "species", "starships", "vehicles"]

# data/raw/swapi in the repo root, regardless of where the script is run from
RAW_DIR = Path(__file__).resolve().parents[1] / "data" / "raw" / "swapi"


def fetch_all(session: requests.Session, endpoint: str) -> list[dict]:
    """Fetch every record of an endpoint by following the paginated `next` links."""
    records = []
    url = f"{BASE_URL}/{endpoint}/"

    while url:
        response = session.get(url, timeout=30)
        response.raise_for_status()  # fail loudly instead of landing partial data
        page = response.json()
        records.extend(page["results"])
        url = page["next"]  # None on the last page, which ends the loop

    # Verify all pages have been extracted
    if len(records) != page["count"]:
        raise RuntimeError(f"{endpoint}: expected {page['count']} records, got {len(records)}")

    return records


def main() -> None:
    loaded_at = datetime.now(timezone.utc).isoformat()

    # Step 1: fetch every endpoint into memory. If any request fails, the script stops
    # here and the existing files in data/raw/swapi are left untouched, so the raw layer is
    # never a mix of old and new runs (all-or-nothing).
    data = {}
    with requests.Session() as session:
        for endpoint in ENDPOINTS:
            data[endpoint] = fetch_all(session, endpoint)
            print(f"fetched {endpoint:<10} {len(data[endpoint]):>4} records")

    # Step 2: only once everything succeeded, write all files
    RAW_DIR.mkdir(parents=True, exist_ok=True)
    for endpoint, records in data.items():
        # Loader metadata column: when data was fetched
        for record in records:
            record["_loaded_at"] = loaded_at

        path = RAW_DIR / f"{endpoint}.json"
        path.write_text(json.dumps(records, indent=2, ensure_ascii=False), encoding="utf-8")
        print(f"wrote   {path.relative_to(RAW_DIR.parents[1])}")


if __name__ == "__main__":
    main()
