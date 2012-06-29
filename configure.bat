
md log
md log\archived

mkdir lib\vendor
mkdir spec\vendor
mkdir bin-vendor

IF EXIST conf\webtest.yml GOTO end

:copy_config_file
COPY conf\webtest.yml.sample conf\webtest.yml

@echo EDIT conf/webtest.yml
@echo   Set main:apphome

:end