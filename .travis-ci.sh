OPAM_DEPENDS="lwt stringext ssl uri re conduit sexplib fieldslib ipaddr cstruct js_of_ocaml"

case "$OCAML_VERSION,$OPAM_VERSION" in
4.00.1,1.0.0) ppa=avsm/ocaml40+opam10 ;;
4.00.1,1.1.0) ppa=avsm/ocaml40+opam11 ;;
4.01.0,1.0.0) ppa=avsm/ocaml41+opam10 ;;
4.01.0,1.1.0) ppa=avsm/ocaml41+opam11 ;;
4.01.0,1.2.0) ppa=avsm/ocaml41+opam12; pin="add" ;;
4.02.0,1.1.0) ppa=avsm/ocaml42+opam11 ;;
4.02.0,1.2.0) ppa=avsm/ocaml42+opam12; pin="add" ;;
*) echo Unknown $OCAML_VERSION,$OPAM_VERSION; exit 1 ;;
esac

case "$OCAML_VERSION" in
4.00.*) ;;
*) OPAM_DEPENDS="$OPAM_DEPENDS async async_ssl" ;;
esac

echo "yes" | sudo add-apt-repository ppa:$ppa
sudo apt-get update -qq
sudo apt-get install -qq ocaml ocaml-native-compilers camlp4-extra opam time libssl-dev

export OPAMYES=1
export OPAMVERBOSE=1
echo OCaml version
ocaml -version
echo OPAM versions
opam --version
opam --git-version

opam init git://github.com/ocaml/opam-repository
opam pin $pin conduit git://github.com/mirage/ocaml-conduit
opam pin $pin mirage-http git://github.com/mirage/mirage-http
opam install ${OPAM_DEPENDS}

eval `opam config env`
make NETTESTS=--enable-nettests
make test
make clean
# Test out some upstream users of Cohttp
opam pin cohttp .

unset OPAMVERBOSE
opam install github cowabloga mirage-www -j 2

case "$OCAML_VERSION" in
4.01.0)
  opam install irmin ;;
*) echo Skipping irmin ;;
esac
