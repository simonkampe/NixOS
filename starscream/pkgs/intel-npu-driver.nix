{ pkgs, ... }:

let
  # maintainers seem to be already on the update of level-zero, this is the patch that makes it the driver compile
  update-npu-ext-patch = pkgs.fetchpatch {
    name = "update-npu-ext-patch";
    url = "https://github.com/intel/level-zero-npu-extensions/commit/110f48ee8eda22d8b40daeeecdbbed0fc3b08f8b.patch";
    hash = "sha256-Wx1Qy3ZSN37pFq4hOeiVthVXn9TTkJXwEEU9gqTz1qo=";
    stripLen = 1;
    extraPrefix = "third_party/level-zero-npu-extensions/";
  };
in
pkgs.stdenv.mkDerivation {
  pname = "linux-npu-driver";
  version = "1.10.0";

  src = pkgs.fetchFromGitHub {
    fetchSubmodules = true;
    fetchLFS = true;
    owner = "intel";
    repo = "linux-npu-driver";
    rev = "v1.10.0";
    hash = "sha256-/WVj7k6v52Kp1mNU8n2mrql27fo9jVoEYja3zBowITk=";
  };
  outputs = [ "out" "firmware" ];
  patches = [ update-npu-ext-patch ];
  postPatch = ''
    rm -rf third_party/level-zero
    rm third_party/cmake/level-zero.cmake
    rm third_party/cmake/FindLevelZero.cmake
    substituteInPlace third_party/CMakeLists.txt \
      --replace-fail "include(cmake/level-zero.cmake)" ""
    substituteInPlace firmware/CMakeLists.txt \
      --replace-fail "DESTINATION /lib/firmware/updates/intel/vpu/" \
      "DESTINATION $firmware/lib/firmware/intel/vpu/"
    substituteInPlace third_party/level-zero-npu-extensions/ze_graph_ext.h \
      --replace-fail "#include \"ze_api.h\"" "#include <level_zero/ze_api.h>"
    substituteInPlace umd/level_zero_driver/core/source/cmdlist/cmdlist.cpp \
      --replace-fail "ZE_STRUCTURE_TYPE_MUTABLE_GRAPH_ARGUMENT_EXP_DESC" "ZE_STRUCTURE_TYPE_MUTABLE_GRAPH_ARGUMENT_EXP_DESC_DEPRECATED"
  '';
  nativeBuildInputs = [ pkgs.cmake ];
  buildInputs = with pkgs; [
    udev
    boost
    openssl
    level-zero
  ];
  # Optionally provide a meta section for metadata
  meta = {
    description = "Intel® NPU (Neural Processing Unit) Driver";
    homepage = "https://github.com/intel/linux-npu-driver";
    license = pkgs.lib.licenses.mit;
  };
}
