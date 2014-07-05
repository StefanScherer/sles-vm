rem 
rem bin\test-box-vcloud.bat sles11sp3_vcloud.box sles11sp3

set quick=0

if "%1x"=="--quickx" (
  shift
  set quick=1
)
set box_path=%1
set box_name=%2
set box_provider=vcloud
set vagrant_provider=vcloud
set test_src_path=../test/*_spec.rb

set result=0

set tmp_path=boxtest
if exist %tmp_path% rmdir /s /q %tmp_path%

if %quick%==1 goto :do_test


rem tested only with box-provider=vcloud
vagrant plugin install vagrant-%box_provider%
vagrant plugin install vagrant-serverspec

vagrant box remove %box_name% --provider=%box_provider%
vagrant box add %box_name% %box_path%
if ERRORLEVEL 1 set result=%ERRORLEVEL%
if ERRORLEVEL 1 goto :done

@set vcloud_hostname=YOUR-VCLOUD-HOSTNAME
@set vcloud_username=YOUR-VCLOUD-USERNAME
@set vcloud_password=YOUR-VCLOUD-PASSWORD
@set vcloud_org=YOUR-VCLOUD-ORG
@set vcloud_catalog=YOUR-VCLOUD-CATALOG
@set vcloud_vdc=YOUR-VCLOUD-VDC

if "%VAGRANT_HOME%x"=="x" set VAGRANT_HOME=%USERPROFILE%\.vagrant.d

if exist c:\vagrant\resources\test-box-vcloud-credentials.bat call c:\vagrant\resources\test-box-vcloud-credentials.bat

echo Uploading %box_name%.ovf to vCloud %vcloud_hostname% / %vcloud_org% / %vcloud_catalog% / %box_name%
@ovftool --acceptAllEulas --vCloudTemplate --overwrite %VAGRANT_HOME%\boxes\%box_name%\0\%box_provider%\%box_name%.ovf "vcloud://%vcloud_username%:%vcloud_password%@%vcloud_hostname%:443?org=%vcloud_org%&vappTemplate=%box_name%&catalog=%vcloud_catalog%&vdc=%vcloud_vdc%"
if ERRORLEVEL 1 goto :first_upload
goto :test_vagrant_box
:first_upload
@ovftool --acceptAllEulas --vCloudTemplate %VAGRANT_HOME%\boxes\%box_name%\0\%box_provider%\%box_name%.ovf "vcloud://%vcloud_username%:%vcloud_password%@%vcloud_hostname%:443?org=%vcloud_org%&vappTemplate=%box_name%&catalog=%vcloud_catalog%&vdc=%vcloud_vdc%"
if ERRORLEVEL 1 goto :error_vcloud_upload

:test_vagrant_box
@echo.
@echo Sleeping 120 seconds for vCloud to finish vAppTemplate import
@echo Tests with 120 seconds still cause a 500 internal error while powering on
@echo a vApp in vCloud. So be patient until we have a better upload
@echo solution that waits until the import is really finished.
@ping 1.1.1.1 -n 1 -w 120000 > nul

:do_test
set result=0

mkdir %tmp_path%
pushd %tmp_path%
call :create_vagrantfile
set VAGRANT_LOG=debug
echo USERPROFILE = %USERPROFILE%
if exist %USERPROFILE%\.ssh\known_hosts type %USERPROFILE%\.ssh\known_hosts
del /F %USERPROFILE%\.ssh\known_hosts
if exist %USERPROFILE%\.ssh\known_hosts echo known_hosts still here!!
vagrant up --provider=%vagrant_provider%
if ERRORLEVEL 1 set result=%ERRORLEVEL%

set VAGRANT_LOG=warn
@echo Sleep 10 seconds
@ping 1.1.1.1 -n 1 -w 10000 > nul

vagrant destroy -f
if ERRORLEVEL 1 set result=%ERRORLEVEL%
popd

if %quick%==1 goto :done

vagrant box remove %box_name% --provider=%box_provider%
if ERRORLEVEL 1 set result=%ERRORLEVEL%

goto :done

:error_vcloud_upload
echo Error Uploading box to vCloud with ovftool!
goto :done

:create_vagrantfile

rem to test if rsync works
if not exist testdir\testfile.txt (
  mkdir testdir
  echo Works >testdir\testfile.txt
)

echo Vagrant.configure('2') do ^|config^| >Vagrantfile
echo   config.vm.define :"tst" do ^|tst^| >>Vagrantfile
echo     tst.vm.box = "%box_name%" >>Vagrantfile
echo     tst.vm.hostname = "tst"
echo     tst.vm.provider :vcloud do ^|vcloud^| >>Vagrantfile
echo       vcloud.vapp_prefix = "%box_name%" >>Vagrantfile
echo     end >>Vagrantfile
echo     tst.vm.provision :serverspec do ^|spec^| >>Vagrantfile
echo       spec.pattern = '../test/*_spec.rb' >>Vagrantfile
echo     end >>Vagrantfile
echo   end >>Vagrantfile
echo end >>Vagrantfile

exit /b

:done
exit %result%
