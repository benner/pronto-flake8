# [Pre-Alpha] Pronto runner for flake8

Pronto runner for [flake8](http://flake8.pycqa.org/en/latest/), a Python Style Guide Enforcer. [What is Pronto?](https://github.com/mmozuras/pronto)


## Configuration of pronto-flake8
* `flake8` should be in your path.
* pronto-flake8 can be configured by placing a `.pronto_flake8.yml` inside the directory where pronto is run.


Following options are available:

| Option               | Meaning                                | Default                                   |
| -------------------- | -------------------------------------- | ----------------------------------------- |
| flake8_executable      | flake8 executable to call.               | `flake8` (calls `flake8` in `PATH`)           |


Example configuration to call custom flake8 executable:

```yaml
# .pronto_flake8.yml
flake8_executable: '/my/custom/path/flake8'
```
