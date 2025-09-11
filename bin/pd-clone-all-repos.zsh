#!/usr/bin/env zsh
set -e

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
    
    if [[ -d "$dir_name" ]]; then
        echo "[pd-git-update] ${GREEN}PULL${RESET}: '$dir_name'"
        cd "$dir_name"
        git pull origin "$branch_name"
        cd ..  # Return to parent directory
    else
        echo "[pd-git-update] ${YELLOW}CLONE${RESET}: %F{cyan}'$dir_name'"
        git clone -b "$branch_name" "$repo_url" "$dir_name"
    fi
}

## Startup
ssh-add ${HOME}/.ssh/id_penndot_c_tralucke 

pd-git-update "99G" "master" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/99G"

## NEXT: LBIDevOps

# (PBR) Posted and Bonded Roadway Inspections – Jan 2013 

# (BPT) Rural Compliance Review – Aug 2013

# (MCDocs) Mobile Construction Documents – Apr 2014 
pd-git-update "DocsMobile" "master" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/DocsMobile"
pd-git-update "DocsMobileDevOps" "master" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/DocsMobileDevOps"
pd-git-update "DocsMobileIIB" "master" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/DocsMobileIIB"
pd-git-update "DocsMobileJAVA" "master" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/DocsMobileJAVA"

# DL Testing - May 2014
pd-git-update "DLTestingIIB" "master" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/DLTestingIIB"
pd-git-update "DLTestingJava" "master" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/DLTestingJava"

# (MCPSA) Project Site Activity – Sep 2014 

# (MCPL) Punchlist – Jul 2015 

# (MCFA) Mobile Construction Force Accounts – Jan 2017 ???
pd-git-update "ForceAccounts" "master" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/ForceAccounts"

# CID – Mar 2016 
# Replaced by eConcrete

# GeoSnap – May 2016 ??
pd-git-update "GeoSnap" "master" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/GeoSnap"
pd-git-update "GeoSnapJAVA" "master" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/GeoSnapJAVA"

# (MPT) Maintenance and Protection of Traffic - Jan 2017 ???

# (M-609) Roadside Activity Report - Jan 2017 ???

# (CMH) Consultant Mileage and Hours – March 2016 

# CDL Testing – Jun 2016 
pd-git-update "CDL" "master" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/CDL"

# DCS Mobile - Jul 2016 
pd-git-update "DAS" "master" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/DAS"

# (SAIR) Department of Environmental Protection – Oil & Gas Surface Activity Inspection Report – Nov 2016 

# (ENS) Erosion and Sediment Control Visual Site Inspection Report – April 2017 

# (Sub-SAIR) Department of Environmental Protection – Oil & Gas Sub-Surface Activity Inspection Report – Jul 2017 

# (MHL) Mileage & Hours Log – July 2017 ??

# BOMO Docs – July 2017 

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

# Sample ID – Feb 2019 ???

# (VSIR) Visual Site Inspection Report – Mar 2019 ???

# FMD Certs – Dec 2019 
pd-git-update "FMDCerts" "master" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/FMDCerts"
## Disabled?
# pd-git-update "FMDCertsWeb" "development" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/FMDCertsWeb"

# M805 – Jan 2020 

# QA Evals – Apr 2020 

# Motorcycle Safety Program – May 2021

# (LBI) Local Bridge Inventory  – May 2020 

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

# eConcrete - Dec 2023 
pd-git-update "eConcrete" "main" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/eConcrete"
pd-git-update "eConcreteDevOps" "master" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/eConcreteDevOps"
pd-git-update "eConcreteJAVA" "development" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/eConcreteJAVA"
pd-git-update "eConcreteWEB" "development" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/eConcreteWEB"

# (EESafety) Employee Safety – Dec 2024 
pd-git-update "EESafety" "main" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/EESafety"
pd-git-update "EESafetyDevOps" "development" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/EESafetyDevOps"
pd-git-update "EESafetyJAVA" "development" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/EESafetyJAVA"
pd-git-update "EESafetyWeb" "development" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/EESafetyWeb"

# (MSI) Mobile Safety Inspections – Aug 2025 

# Construction AAR - Aug 2025
pd-git-update "ConstructionAAR" "feature/v2.0" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/ConstructionAAR"
pd-git-update "ConstructionAARJava" "development" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/ConstructionAARJava"
pd-git-update "ConstructionAARWeb" "130972-AARProjectAspects" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/ConstructionAARWeb"

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
# pd-git-update "esec_custompages" "development" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/esec_custompages"
# pd-git-update "framework-java" "master" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/framework-java"
# pd-git-update "Helpfiles" "master" "penndotvso@vs-ssh.visualstudio.com:v3/penndotvso/SES-Mobile/Helpfiles"
