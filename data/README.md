# Data

The raw file is not stored in this repository. Download it from Kaggle:

**Lazada Indonesian Reviews** by grikomsn
https://www.kaggle.com/datasets/grikomsn/lazada-indonesian-reviews

Only `20191002-reviews.csv` is used. Put it at `data/raw/20191002-reviews.csv`.

With the Kaggle CLI:

```bash
kaggle datasets download -d grikomsn/lazada-indonesian-reviews -f 20191002-reviews.csv -p data/raw
unzip -o data/raw/20191002-reviews.csv.zip -d data/raw && rm data/raw/20191002-reviews.csv.zip
```

The file has 203,787 rows and 15 columns. It was scraped from five Lazada Indonesia
category pages on 2 October 2019. Reviewer names are partly masked by Lazada; the
load step hashes them for deduplication and does not keep them.
