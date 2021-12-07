{ lib
, buildPythonPackage
, fetchPypi
, pytest
, isPy27
}:

buildPythonPackage rec {
  version = "0.5.0";
  pname = "pysnooper";

  src = fetchPypi {
    inherit version;
    pname = "PySnooper";
    sha256 = "ec3c4648dbe3bc848a0ecea5e2ffea3a5947797599afb627a68ac4e44454116b";
  };

  # test dependency python-toolbox fails with py27
  doCheck = !isPy27;

  checkInputs = [
    pytest
  ];

  meta = with lib; {
    description = "A poor man's debugger for Python";
    homepage = "https://github.com/cool-RR/PySnooper";
    license = licenses.mit;
    maintainers = with maintainers; [ seqizz ];
  };
}
