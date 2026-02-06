#!/usr/bin/env zsh
set -e

# Clone all repos here
BASE_DIR="${HOME}/Code/penndotvso"

# Colors
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
RESET="\033[0m"

function pd-git-update {
    local dir_name="$1"
    local repo_url="$2"
    local branch_name="$3"  # Optional: only if you want to override

    if [[ -z "$dir_name" || -z "$repo_url" ]]; then
        echo "Error: Missing parameters. Usage: pd-git-update <directory> <repo_url> [branch]"
        return 1
    fi

    local work_dir="${BASE_DIR}/${dir_name}"

    if [[ -z "$branch_name" ]]; then
        branch_name=$(git ls-remote --symref "$repo_url" HEAD | awk '/^ref:/ {sub(/refs\/heads\//, "", $2); print $2}')

        if [[ -z "$branch_name" ]]; then
            echo "[pd-git-update] ${RED}ERROR${RESET}: Could not detect default branch for '$dir_name'"
            return 1
        fi
    fi

    if [[ -d "$work_dir" ]]; then
        echo "[pd-git-update] ${GREEN}PULL${RESET}: '$dir_name' ($branch_name)"
        git -C "${work_dir}" pull origin "$branch_name"
    else
        echo "[pd-git-update] ${YELLOW}CLONE${RESET}: '$dir_name' ($branch_name)"
        git clone -b "$branch_name" "$repo_url" "${work_dir}"
    fi
}

## Startup
ssh-add ${HOME}/.ssh/id_penndot_c_tralucke 
mkdir -p "${BASE_DIR}"

pd-git-update "99G" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/99G"
pd-git-update "99GMobileIIB" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/99GMobileIIB"

# (PBR) Posted and Bonded Roadway Inspections – Jan 2013
pd-git-update "PBR" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/PBR"
pd-git-update "PBRDevOps" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/PBRDevOps"
pd-git-update "PBRJAVA" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/PBRJAVA"

# (BPT) Rural Compliance Review – Aug 2013
# Discontinued

# (MCDocs) Mobile Construction Documents – Apr 2014
pd-git-update "DocsMobile" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/DocsMobile"
pd-git-update "DocsMobileDevOps" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/DocsMobileDevOps"
pd-git-update "DocsMobileIIB" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/DocsMobileIIB"
pd-git-update "DocsMobileJAVA" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/DocsMobileJAVA"

# DL Testing - May 2014
pd-git-update "NCDL" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/NCDL"
pd-git-update "DLTestingIIB" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/DLTestingIIB"
pd-git-update "DLTestingJava" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/DLTestingJava"

# (MCPSA) Project Site Activity – Sep 2014
pd-git-update "PSA" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/PSA"
pd-git-update "MCPSAJAVA" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/MCPSAJAVA"

# (MCPL) Punchlist – Jul 2015
pd-git-update "PunchList" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/PunchList"
pd-git-update "PunchListDevOps" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/PunchListDevOps"
pd-git-update "PunchListJAVA" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/PunchListJAVA"

# (MCFA) Mobile Construction Force Accounts – Jan 2017 ???
pd-git-update "ForceAccounts" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/ForceAccounts"
pd-git-update "MCFSAJAVA" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/MCFSAJAVA"
pd-git-update "MCFSAJAVADevOps" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/MCFSAJAVADevOps"

# CID – Mar 2016 
# Replaced by eConcrete

# GeoSnap – May 2016 ??
pd-git-update "GeoSnap" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/GeoSnap"
pd-git-update "GeoSnapJAVA" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/GeoSnapJAVA"

# (MPT) Maintenance and Protection of Traffic - Jan 2017 ???
pd-git-update "MPT" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/MPT"
pd-git-update "MPTDevOps" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/MPTDevOps"
pd-git-update "MPTJAVA" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/MPTJAVA"
pd-git-update "MPTWEB" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/MPTWEB"

# (M-609) Roadside Activity Report - Jan 2017 ???
pd-git-update "M609" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/M609"
pd-git-update "M609DevOps" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/M609DevOps"
pd-git-update "M609JAVA" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/M609JAVA"
pd-git-update "M609WEB" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/M609WEB"

# (CMH) Consultant Mileage and Hours – March 2016 
# Replaced by MHL

# CDL Testing – Jun 2016
pd-git-update "CDL" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/CDL"

# DCS Mobile - Jul 2016
pd-git-update "DAS" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/DAS"

# (SAIR) Department of Environmental Protection – Oil & Gas Surface Activity Inspection Report – Nov 2016 
# Removed after DEP Split

# (ENS) Erosion and Sediment Control Visual Site Inspection Report – Apr 2017 
# Replaced by VSIR

# (Sub-SAIR) Department of Environmental Protection – Oil & Gas Sub-Surface Activity Inspection Report – Jul 2017 
# Removed after DEP Split

# (MHL) Mileage & Hours Log – Jul 2017 ??
pd-git-update "MHL" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/MHL"
pd-git-update "MHLDevOps" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/MHLDevOps"
pd-git-update "MHLJAVA" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/MHLJAVA"

# BOMO Docs – Jul 2017 
# Uses MCDocs repos

# ePayroll – Dec 2017
pd-git-update "ePayroll" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/ePayroll"
pd-git-update "ePayrollIIB" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/ePayrollIIB"
pd-git-update "ePayrollJAVA" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/ePayrollJAVA"
pd-git-update "ePayrollWEB" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/ePayrollWEB"

# DL Exam Schedule - Jul 2018
pd-git-update "DLESDPWeb" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/DLESDPWeb"

# 99G – Feb 2019
pd-git-update "99G" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/99G"
pd-git-update "99GMobileIIB" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/99G"

# PA Video – Mar 2019
pd-git-update "GeoVideo" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/GeoVideo"
pd-git-update "VideoViewerWeb" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/VideoViewerWeb"

# Sample ID – Feb 2019
pd-git-update "TR-447" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/TR-447"
pd-git-update "TR447DevOps" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/TR447DevOps"
pd-git-update "TR447JAVA" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/TR447JAVA"

# (VSIR) Visual Site Inspection Report – Mar 2019
pd-git-update "MS4VSIREvals" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/VSIR"
pd-git-update "VSIRDevOps" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/VSIRDevOps"
pd-git-update "VSIRJAVA" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/VSIRJAVA"

# FMD Certs – Dec 2019
pd-git-update "FMDCerts" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/FMDCerts"
# pd-git-update "FMDCertsWeb" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/FMDCertsWeb"

# M805 – Jan 2020
pd-git-update "M805" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/M805"
pd-git-update "M805DevOps" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/M805DevOps"
# pd-git-update "M805IIB" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/M805IIB"
pd-git-update "M805JAVA" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/M805JAVA"
pd-git-update "M805SwiftUI" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/M805SwiftUI"

# QA Evals – Apr 2020
pd-git-update "QAEvals" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/QAEvals"
pd-git-update "QAEvalsDevOps" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/QAEvalsDevOps"
pd-git-update "QAEvalsJAVA" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/QAEvalsJAVA"
pd-git-update "QAEvalsWEB" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/QAEvalsWEB"

# Motorcycle Safety Program – May 2021
pd-git-update "MSP" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/MSP"
pd-git-update "MSPDevOps" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/MSPDevOps"
pd-git-update "MSPJAVA" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/MSPJAVA"
pd-git-update "MSPWeb" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/MSPWeb"

# (LBI) Local Bridge Inventory  – May 2020
pd-git-update "LBIDevOps" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/LBIDevOps"
pd-git-update "LBR" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/LBR"
pd-git-update "LBRJAVA" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/LBRJAVA"

# County Certs – Oct 2020
pd-git-update "CountyCertsDB" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/CountyCertsDB"
pd-git-update "CountyCertsDevOps" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/CountyCertsDevOps"
pd-git-update "CountyCertsJAVA" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/CountyCertsJAVA"
pd-git-update "CountyCertsWeb" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/CountyCertsWeb"

# AVIRP-FG – Jun 2021
pd-git-update "AVIRPFG" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/AVIRPFG"
pd-git-update "AVIRPFGDevOps" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/AVIRPFGDevOps"
pd-git-update "AVIRPFGJAVA" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/AVIRPFGJAVA"
pd-git-update "AVIRPFGWeb" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/AVIRPFGWeb"

# BOMO Video – June 2021 
# Uses PA Video

# (SEMPEvals) Strategic Environmental Management Program – Jun 2021
pd-git-update "FacilityEvals" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/FacilityEvals"
pd-git-update "FacilityEvalsDevOps" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/FacilityEvalsDevOps"
pd-git-update "FacilityEvalsJAVA" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/FacilityEvalsJAVA"
pd-git-update "FacilityEvalsWeb" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/FacilityEvalsWeb"

# eTicketing – Jul 2021
pd-git-update "eTicketing" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/eTicketing"
pd-git-update "eTicketingDevOps" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/eTicketingDevOps"
pd-git-update "eTicketingJAVA" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/eTicketingJAVA"
pd-git-update "eTicketingWeb" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/eTicketingWeb"

# (SCMEvals) Stormwater Control Measure Evals – May 2022
pd-git-update "MS4Evals" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/MS4Evals"
pd-git-update "MS4DevOps" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/MS4DevOps"
pd-git-update "MS4JAVA" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/MS4JAVA"

# eConcrete - Dec 2023
pd-git-update "eConcrete" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/eConcrete" "devops"
pd-git-update "eConcreteDevOps" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/eConcreteDevOps"
pd-git-update "eConcreteJAVA" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/eConcreteJAVA"
pd-git-update "eConcreteWEB" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/eConcreteWEB"

# (EESafety) Employee Safety – Dec 2024
pd-git-update "EESafety" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/EESafety"
pd-git-update "EESafetyDevOps" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/EESafetyDevOps"
pd-git-update "EESafetyJAVA" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/EESafetyJAVA"
pd-git-update "EESafetyWeb" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/EESafetyWeb"

# (MSI) Mobile Safety Inspections – Aug 2025
pd-git-update "SafetyInspections" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/SafetyInspections" "feature/unifiedBuild"
pd-git-update "SafetyInspectionsJAVA" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/SafetyInspectionsJAVA"
pd-git-update "SafetyInspectionsWeb" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/SafetyInspectionsWeb"

# Construction AAR - Aug 2025
pd-git-update "ConstructionAAR" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/ConstructionAAR" "release/v2.1"
pd-git-update "ConstructionAARJava" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/ConstructionAARJava"
pd-git-update "ConstructionAARWeb" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/ConstructionAARWeb"

# Frameworks
pd-git-update "PDKit" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/PDKit"
pd-git-update "POD-PDAzureLogin" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/POD-PDAzureLogin"
pd-git-update "POD-PDPdfKit" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/POD-PDPdfKit"
pd-git-update "POD-PDUnifiedFramework" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/POD-PDUnifiedFramework"
pd-git-update "POD-Scripts" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/POD-Scripts"

# ? Projects
# pd-git-update "PennLog" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/PennLog"
# pd-git-update "VirtualAssistant" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/VirtualAssistant"

# Other
# pd-git-update "ADP-ADF" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/ADP-ADF"
# pd-git-update "ADPModelJava" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/ADPModelJava"
# pd-git-update "ADPModelWeb" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/ADPModelWeb"
# pd-git-update "AKS_POC" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/AKS_POC"
# pd-git-update "azure-admin" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/azure-admin"
# pd-git-update "azure-apim" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/azure-apim"
# pd-git-update "AzureWeb" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/AzureWeb"
# pd-git-update "CommonControlsDemo" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/CommonControlsDemo"
# pd-git-update "CommonJavaApi" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/CommonJavaApi"
# pd-git-update "DashboardWeb" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/DashboardWeb"
# pd-git-update "DevOps" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/DevOps"
# pd-git-update "ecs-java" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/ecs-java"
pd-git-update "esec_custompages" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/esec_custompages"
# pd-git-update "framework-java" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/framework-java"
pd-git-update "Helpfiles" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/Helpfiles"
# pd-git-update "MinimalClientApp" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/MinimalClientApp"
# pd-git-update "MobileApiKey" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/MobileApiKey"
# pd-git-update "MobileAuthentication" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/MobileAuthentication"
# pd-git-update "MobileGateway" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/MobileGateway"
# pd-git-update "mobladm-java" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/mobladm-java"
# pd-git-update "MOBLADMJava" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/MOBLADMJava"
# pd-git-update "MOBLADMWeb" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/MOBLADMWeb"
# pd-git-update "MPDPlayground" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/MPDPlayground"
pd-git-update "npm-packages" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/npm-packages"

# pd-git-update "PDKitStarterProject" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/PDKitStarterProject"
# pd-git-update "PDMobileAPIStarter" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/PDMobileAPIStarter"
