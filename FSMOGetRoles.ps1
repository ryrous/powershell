### Get FSMO Roles ###
Get-ADForest domain.com | FT SchemaMaster
Get-ADForest domain.com | FT DomainNamingMaster
Get-ADForest domain.com | FT PDCEmulator
Get-ADForest domain.com | FT InfrastructureMaster
Get-ADForest domain.com | FT RIDMaster
