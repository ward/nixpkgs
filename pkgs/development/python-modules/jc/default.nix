{ lib
, buildPythonPackage
, fetchFromGitHub
, ruamel-yaml
, xmltodict
, pygments
, pytestCheckHook
, pythonOlder
}:

buildPythonPackage rec {
  pname = "jc";
  version = "1.17.3";
  disabled = pythonOlder "3.6";

  src = fetchFromGitHub {
    owner = "kellyjonbrazil";
    repo = pname;
    rev = "v${version}";
    sha256 = "0jnk61a4c8pvbxcfjlz90xapj5xggzgi3i2x208msr6qmah9z1rf";
  };

  propagatedBuildInputs = [ ruamel-yaml xmltodict pygments ];

  checkInputs = [ pytestCheckHook ];

  pythonImportsCheck = [ "jc" ];

  # tests require timezone to set America/Los_Angeles
  doCheck = false;

  meta = with lib; {
    description = "This tool serializes the output of popular command line tools and filetypes to structured JSON output";
    homepage = "https://github.com/kellyjonbrazil/jc";
    license = licenses.mit;
    maintainers = with maintainers; [ atemu ];
  };
}
