# Profile_pulp

## Known issues

- Disable postgres module

```
dnf -qy module disable postgresql
```

- Pulpcore repo management does not work due to dependency cycle, add the following repo config manually:

```
[pulpcore]
name=Pulpcore 3.9
baseurl=https://yum.theforeman.org/pulpcore/3.9/el8/x86_64/
enabled=1
gpgcheck=1
gpgkey=https://yum.theforeman.org/pulpcore/3.9/GPG-RPM-KEY-pulpcore
module_hotfixes=1
```
