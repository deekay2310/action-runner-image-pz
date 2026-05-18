#!/bin/bash -e
################################################################################
##  File:  os.sh
##  Desc:  Helper functions for OS releases
################################################################################
is_rhel9() {
    source /etc/os-release && [[ "$VERSION_ID" == 9* ]]
}

is_rhel10() {
    source /etc/os-release && [[ "$VERSION_ID" == 10* ]]
}
