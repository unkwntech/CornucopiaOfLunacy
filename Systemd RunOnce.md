# RunOnce

Enables scripts that run once at startup.

## Runonce

```bash
sudo mkdir -p /etc/local/runonce.d/ran
sudo nano /usr/local/bin/runonce
```

```bash
#!/bin/sh
# This is ripped almost perfectly from https://serverfault.com/a/148355/51157
for file in /etc/local/runonce.d/*
do
    if [ ! -f "$file" ]
    then
        continue
    fi
    "$file"
    fn=`basename $file`
    mv "$file" "/etc/local/runonce.d/ran/$fn.$(date +%Y%m%dT%H%M%S)"
    logger -t runonce -p local3.info "$file"
done
```

## Systemd setup


```bash
sudo nano /etc/systemd/system/runonce.service
```

```bash
# /etc/systemd/system/runonce.service
[Unit]
Description=Runonce scripts
Wants=network-online.target
After=network.target

[Service]
ExecStart=/usr/local/bin/runonce

[Install]
WantedBy=multi-user.target
```

```bash
sudo systemctl start runonce
sudo systemctl status runonce
```

After confirming that runonce is working.

```bash
sudo systemctl enable runonce
```