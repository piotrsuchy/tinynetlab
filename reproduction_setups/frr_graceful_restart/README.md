## Reproduction steps for [FRR issue: Graceful Restart procedures do not apply when hard-administrative-reset flag is disabled](https://track.akamai.com/jira/browse/PAR3-161)


### Instruction

1. Build the docker image, it uses frr-10.1.1 by default but you can tweak it to checkout on different tag, it builds and installs frr from source:<br>
`docker build -t frr-graceful-restart:frr10.1.1 .`

2. Run setup script, it should run 2 frr containers, prepare interfaces, run respective daemons, load configs and inject kernel routes on routeserver1 box:<br>

3. Start interactive terminal session with hypervisor:<br>
`docker exec -it hypervisor bash`

4. Check if the session with routeserver1 is up `vtysh -c 'show bgp sum'` and if the routes have been instaled to kernel `ip r`

5. Run rtmon process to track if routes are being withdrawn from kernel:<br>
`rtmon -family inet route file $(hostname -s)_rtmon.log &`

6. Administratively clear BGP session with 2002:db8::2:<br>
`vtysh -c 'clear bgp 2001:db8::2'`

7. Read monitor file, you should see bunch of deletes and then installs into kernel after the session comes back up:<br>
`ip monitor fil $(hostname -s)_rtmon.log`