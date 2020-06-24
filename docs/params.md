# Parameter reference

## Parameters controlling the pipeline behavior

The following parameters control the pipeline as a whole. These can be specified on the command line using the double-dash, e.g., `--my-parameter myvalue` or inside a YAML file as a key-value pair:

```
my-parameter: myvalue
```

Mandatory parameters:

* `--in /local/path` - specifies location of the data

Optional parameters:

* `--sample-name myname` - the name of the experiment/specimen. By default, mcmicro extracts this from the path supplied to `--in`.
* `--start-at` - name of the starting step in the pipeline. Must be one of `raw`, `illumination`, `registration`, `dearray` (TMA only), `probability-maps`, `segmentation`, `quantification`, `cell-states`. Default: `registration`.


## Parameters controlling the execution environment

## Parameters of individual modules

