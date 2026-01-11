# ibraheemaj.com


# Process
## Run `1bbb`
* Development: Run 

```bash
swift run 
    --package-path tools/blogbot 1bbb 
    --repos-file articles.json 
    --conversion-script tools/convert-notebooks/main.py
```

## Jupyter Notebook Conversion
Ensure pandoc installed. See https://github.com/jupyter/nbconvert for more info. Usually this is as trivial as running `brew install pandoc`.

## Useful tools
* `papermill`: for jupyter notebooks


# TODOs
- [ ] Custom domain for the blog
    - https://docs.github.com/en/pages/configuring-a-custom-domain-for-your-github-pages-site
    - https://docs.astro.build/en/guides/deploy/github/#using-github-pages-with-a-custom-domain