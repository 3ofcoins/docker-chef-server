Change Log
==========

2018-10-19: 12.18.14
--------------------
- Upgraded Chef Server to 12.18.14 and Chef Client to 14.6.47
- Used Ubuntu 16.04 LTS as base image (#8)
- Added automatic `chef-server-ctl upgrade` (basing off #8, adapted to fit
 [Chef Server upgrade procedure](https://docs.chef.io/upgrade_server.html#standalone));
 added upgrade instructions
- Removed `shmall` and `shmat` sysctls (Chef Server 12.16.2 upgraded
  PostgreSQL to 9.6, which makes these settings unnecessary)
- Introduced this changelog
