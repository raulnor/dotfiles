#!/usr/bin/env zsh
set -e

# Clone all repos here
BASE_DIR="${HOME}/Code/penndotvso"

# Colors
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
RESET="\033[0m"

function pd-git-update {
    local dir_name="$1"
    local branch_name="$2"
    local repo_url="$3"
    
    # Check if all parameters are provided
    if [[ -z "$dir_name" || -z "$branch_name" || -z "$repo_url" ]]; then
        echo "Error: Missing parameters. Usage: pd-git-update <directory> <branch> <repo_url>"
        return 1
    fi

    local work_dir="${BASE_DIR}/${dir_name}"

    if [[ -d "$work_dir" ]]; then
        echo "[pd-git-update] ${GREEN}PULL${RESET}: '$dir_name'"
        git -C "${work_dir}" pull origin "$branch_name"
    else
        echo "[pd-git-update] ${YELLOW}CLONE${RESET}: '$dir_name'"
        git clone -b "$branch_name" "$repo_url" "${work_dir}"
    fi
}

## Startup
ssh-add ${HOME}/.ssh/id_penndot_c_tralucke 
mkdir -p "${BASE_DIR}"

pd-git-update "99G" "master" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/99G"

# (PBR) Posted and Bonded Roadway Inspections – Jan 2013 
pd-git-update "PBR" "master" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/PBR"
pd-git-update "PBRDevOps" "master" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/PBRDevOps"
pd-git-update "PBRJAVA" "development" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/PBRJAVA"

# (BPT) Rural Compliance Review – Aug 2013
# Discontinued

# (MCDocs) Mobile Construction Documents – Apr 2014 
pd-git-update "DocsMobile" "master" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/DocsMobile"
pd-git-update "DocsMobileDevOps" "master" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/DocsMobileDevOps"
pd-git-update "DocsMobileIIB" "master" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/DocsMobileIIB"
pd-git-update "DocsMobileJAVA" "master" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/DocsMobileJAVA"

# DL Testing - May 2014
pd-git-update "NCDL" "master" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/NCDL"
pd-git-update "DLTestingIIB" "master" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/DLTestingIIB"
pd-git-update "DLTestingJava" "master" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/DLTestingJava"

# (MCPSA) Project Site Activity – Sep 2014 
pd-git-update "PSA" "master" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/PSA"
pd-git-update "MCPSAJAVA" "development" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/MCPSAJAVA"

# (MCPL) Punchlist – Jul 2015 
pd-git-update "PunchList" "master" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/PunchList"
pd-git-update "PunchListDevOps" "development" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/PunchListDevOps"
pd-git-update "PunchListJAVA" "master" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/PunchListJAVA"

# (MCFA) Mobile Construction Force Accounts – Jan 2017 ???
pd-git-update "ForceAccounts" "master" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/ForceAccounts"
pd-git-update "MCFSAJAVA" "master" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/MCFSAJAVA"
pd-git-update "MCFSAJAVADevOps" "development" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/MCFSAJAVADevOps"

# CID – Mar 2016 
# Replaced by eConcrete

# GeoSnap – May 2016 ??
pd-git-update "GeoSnap" "master" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/GeoSnap"
pd-git-update "GeoSnapJAVA" "master" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/GeoSnapJAVA"

# (MPT) Maintenance and Protection of Traffic - Jan 2017 ???
pd-git-update "MPT" "master" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/MPT"
pd-git-update "MPTDevOps" "master" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/MPTDevOps"
pd-git-update "MPTJAVA" "development" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/MPTJAVA"
pd-git-update "MPTWEB" "development" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/MPTWEB"

# (M-609) Roadside Activity Report - Jan 2017 ???
pd-git-update "M609" "master" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/M609"
pd-git-update "M609DevOps" "master" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/M609DevOps"
pd-git-update "M609JAVA" "development" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/M609JAVA"
pd-git-update "M609WEB" "development" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/M609WEB"

# (CMH) Consultant Mileage and Hours – March 2016 
# Replaced by MHL

# CDL Testing – Jun 2016 
pd-git-update "CDL" "master" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/CDL"

# DCS Mobile - Jul 2016 
pd-git-update "DAS" "master" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/DAS"

# (SAIR) Department of Environmental Protection – Oil & Gas Surface Activity Inspection Report – Nov 2016 
# Removed after DEP Split

# (ENS) Erosion and Sediment Control Visual Site Inspection Report – Apr 2017 
# Replaced by VSIR

# (Sub-SAIR) Department of Environmental Protection – Oil & Gas Sub-Surface Activity Inspection Report – Jul 2017 
# Removed after DEP Split

# (MHL) Mileage & Hours Log – Jul 2017 ??
pd-git-update "MHL" "master" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/MHL"
pd-git-update "MHLDevOps" "development" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/MHLDevOps"
pd-git-update "MHLJAVA" "development" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/MHLJAVA"

# BOMO Docs – Jul 2017 
# Uses MCDocs repos

# ePayroll – Dec 2017 
pd-git-update "ePayroll" "master" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/ePayroll"
pd-git-update "ePayrollIIB" "master" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/ePayrollIIB"
pd-git-update "ePayrollJAVA" "master" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/ePayrollJAVA"
pd-git-update "ePayrollWEB" "master" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/ePayrollWEB"

# DL Exam Schedule - Jul 2018
pd-git-update "DLESDPWeb" "development" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/DLESDPWeb"

# 99G – Feb 2019 
pd-git-update "99G" "master" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/99G"
pd-git-update "99GMobileIIB" "master" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/99G"

# PA Video – Mar 2019 
pd-git-update "GeoVideo" "master" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/GeoVideo"
pd-git-update "VideoViewerWeb" "development" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/VideoViewerWeb"

# Sample ID – Feb 2019
pd-git-update "TR-447" "master" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/TR-447"
pd-git-update "TR447DevOps" "master" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/TR447DevOps"
pd-git-update "TR447JAVA" "development" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/TR447JAVA"

# (VSIR) Visual Site Inspection Report – Mar 2019 
pd-git-update "MS4VSIREvals" "master" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/VSIR"
pd-git-update "VSIRDevOps" "master" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/VSIRDevOps"
pd-git-update "VSIRJAVA" "development" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/VSIRJAVA"

# FMD Certs – Dec 2019 
pd-git-update "FMDCerts" "master" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/FMDCerts"
# pd-git-update "FMDCertsWeb" "development" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/FMDCertsWeb"

# M805 – Jan 2020 
pd-git-update "M805" "master" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/M805"
pd-git-update "M805DevOps" "development" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/M805DevOps"
# pd-git-update "M805IIB" "master" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/M805IIB"
pd-git-update "M805JAVA" "development" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/M805JAVA"
pd-git-update "M805SwiftUI" "main" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/M805SwiftUI"

# QA Evals – Apr 2020 
pd-git-update "QAEvals" "master" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/QAEvals"
pd-git-update "QAEvalsDevOps" "development" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/QAEvalsDevOps"
pd-git-update "QAEvalsJAVA" "development" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/QAEvalsJAVA"
pd-git-update "QAEvalsWEB" "development" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/QAEvalsWEB"

# Motorcycle Safety Program – May 2021
pd-git-update "MSP" "master" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/MSP"
pd-git-update "MSPDevOps" "master" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/MSPDevOps"
pd-git-update "MSPJAVA" "master" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/MSPJAVA"
pd-git-update "MSPWeb" "master" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/MSPWeb"

# (LBI) Local Bridge Inventory  – May 2020 
pd-git-update "LBIDevOps" "master" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/LBIDevOps"
pd-git-update "LBR" "master" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/LBR"
pd-git-update "LBRJAVA" "master" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/LBRJAVA"

# County Certs – Oct 2020  
pd-git-update "CountyCertsDB" "master" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/CountyCertsDB"
pd-git-update "CountyCertsDevOps" "development" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/CountyCertsDevOps"
pd-git-update "CountyCertsJAVA" "development" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/CountyCertsJAVA"
pd-git-update "CountyCertsWeb" "development" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/CountyCertsWeb"

# AVIRP-FG – Jun 2021 
pd-git-update "AVIRPFG" "master" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/AVIRPFG"
pd-git-update "AVIRPFGDevOps" "master" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/AVIRPFGDevOps"
pd-git-update "AVIRPFGJAVA" "master" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/AVIRPFGJAVA"
pd-git-update "AVIRPFGWeb" "master" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/AVIRPFGWeb"

# BOMO Video – June 2021 
# Uses PA Video

# (SEMPEvals) Strategic Environmental Management Program – Jun 2021 
pd-git-update "FacilityEvals" "master" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/FacilityEvals"
pd-git-update "FacilityEvalsDevOps" "master" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/FacilityEvalsDevOps"
pd-git-update "FacilityEvalsJAVA" "development" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/FacilityEvalsJAVA"
pd-git-update "FacilityEvalsWeb" "development" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/FacilityEvalsWeb"

# eTicketing – Jul 2021 
pd-git-update "eTicketing" "main" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/eTicketing"
pd-git-update "eTicketingDevOps" "development" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/eTicketingDevOps"
pd-git-update "eTicketingJAVA" "development" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/eTicketingJAVA"
pd-git-update "eTicketingWeb" "development" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/eTicketingWeb"

# (SCMEvals) Stormwater Control Measure Evals – May 2022 
pd-git-update "MS4Evals" "main" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/MS4Evals"
pd-git-update "MS4DevOps" "master" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/MS4DevOps"
pd-git-update "MS4JAVA" "development" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/MS4JAVA"

# eConcrete - Dec 2023 
pd-git-update "eConcrete" "devops" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/eConcrete"
pd-git-update "eConcreteDevOps" "master" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/eConcreteDevOps"
pd-git-update "eConcreteJAVA" "development" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/eConcreteJAVA"
pd-git-update "eConcreteWEB" "development" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/eConcreteWEB"

# (EESafety) Employee Safety – Dec 2024 
pd-git-update "EESafety" "main" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/EESafety"
pd-git-update "EESafetyDevOps" "development" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/EESafetyDevOps"
pd-git-update "EESafetyJAVA" "development" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/EESafetyJAVA"
pd-git-update "EESafetyWeb" "development" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/EESafetyWeb"

# (MSI) Mobile Safety Inspections – Aug 2025 
pd-git-update "SafetyInspections" "feature/unifiedBuild" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/SafetyInspections"
pd-git-update "SafetyInspectionsJAVA" "development" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/SafetyInspectionsJAVA"
pd-git-update "SafetyInspectionsWeb" "development" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/SafetyInspectionsWeb"

# Construction AAR - Aug 2025
pd-git-update "ConstructionAAR" "release/v2.1" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/ConstructionAAR"
pd-git-update "ConstructionAARJava" "development" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/ConstructionAARJava"
pd-git-update "ConstructionAARWeb" "130972-AARProjectAspects" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/ConstructionAARWeb"

# Frameworks
pd-git-update "PDKit" "main" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/PDKit"
pd-git-update "POD-PDAzureLogin" "master" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/POD-PDAzureLogin"
pd-git-update "POD-PDPdfKit" "master" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/POD-PDPdfKit"
pd-git-update "POD-PDUnifiedFramework" "master" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/POD-PDUnifiedFramework"
pd-git-update "POD-Scripts" "master" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/POD-Scripts"

# ? Projects
# pd-git-update "PennLog" "master" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/PennLog"
# pd-git-update "VirtualAssistant" "master" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/VirtualAssistant"

# Other
# pd-git-update "ADP-ADF" "main" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/ADP-ADF"
# pd-git-update "ADPModelJava" "development" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/ADPModelJava"
# pd-git-update "ADPModelWeb" "development" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/ADPModelWeb"
# pd-git-update "AKS_POC" "master" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/AKS_POC"
# pd-git-update "azure-admin" "development" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/azure-admin"
# pd-git-update "azure-apim" "master" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/azure-apim"
# pd-git-update "AzureWeb" "master" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/AzureWeb"
# pd-git-update "CommonControlsDemo" "master" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/CommonControlsDemo"
# pd-git-update "CommonJavaApi" "master" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/CommonJavaApi"
# pd-git-update "DashboardWeb" "development" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/DashboardWeb"
# pd-git-update "DevOps" "development" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/DevOps"
# pd-git-update "ecs-java" "development" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/ecs-java"
pd-git-update "esec_custompages" "master" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/esec_custompages"
# pd-git-update "framework-java" "master" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/framework-java"
pd-git-update "Helpfiles" "master" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/Helpfiles"
# pd-git-update "MinimalClientApp" "main" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/MinimalClientApp"
# pd-git-update "MobileApiKey" "master" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/MobileApiKey"
# pd-git-update "MobileAuthentication" "master" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/MobileAuthentication"
# pd-git-update "MobileGateway" "master" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/MobileGateway"
# pd-git-update "mobladm-java" "master" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/mobladm-java"
# pd-git-update "MOBLADMJava" "master" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/MOBLADMJava"
# pd-git-update "MOBLADMWeb" "master" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/MOBLADMWeb"
# pd-git-update "MPDPlayground" "main" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/MPDPlayground"
pd-git-update "npm-packages" "development" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/npm-packages"

# pd-git-update "PDKitStarterProject" "main" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/PDKitStarterProject"
# pd-git-update "PDMobileAPIStarter" "development" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/PDMobileAPIStarter"
