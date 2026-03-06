FROM r.xmox.nl/mox:v0.0.15

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["mox", "serve"]
