<#
-Create one Active Directory site per location. If the bandwidth between locations is above 10 Mbit/second and reliable, and you don't want to segment services or subnets, create one Active Directory site for these locations.
-Configure one Active Directory site link between two Active Directory sites.
-Configure a catch-all subnet, for instance a 10.0.0.0/8 subnet, in your main location and create subnets with smaller ranges, for instance 10.1.0.0/16 and 10.3.1.0/24 subnets, for other locations.
-Do not disable the Bridge all site links option for all IP-based site links and all SMTP-based site links.
-Do not enable the Ignore schedules option for all IP-based site links.
-Keep Bridge all site links enabled.
-Keep the ISTG enabled.
-Keep the KCC enabled.
-Keep Strict Replication Consistency enabled.
-Define a process where networking admins communicate changes in their environment to Active Directory admins, so they can optimize Active Directory to take advantage of these changes.
-Do not link Group Policy objects to Active Directory sites, if you can avoid it.”
#>
# Create New Site in AD
New-ADReplicationSite -Name "Site2”
