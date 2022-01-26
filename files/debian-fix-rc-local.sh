#!/bin/sh

touch /target/etc/rc.local
echo -e '#!/bin/bash' >> /target/etc/rc.local
echo -e '\n\n\n\n\n\n' >> /target/etc/rc.local
echo -e 'exit 0' >> /target/etc/rc.local
echo -e '\n\n' >> /target/etc/rc.local
chmod 755 /target/etc/rc.local


exit 0

