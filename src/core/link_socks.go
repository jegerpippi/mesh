package core

import (
	"fmt"
	"net"
	"net/url"
	"strings"

	"golang.org/x/net/proxy"
)

type linkSOCKS struct {
	*links
}

func (l *links) newLinkSOCKS() *linkSOCKS {
	lt := &linkSOCKS{
		links: l,
	}
	return lt
}

func (l *linkSOCKS) dial(url *url.URL, options linkOptions) error {
	info := linkInfoFor("socks", "", url.Path)
	if l.links.isConnectedTo(info) {
		return nil
	}
	proxyAuth := &proxy.Auth{}
	proxyAuth.User = url.User.Username()
	proxyAuth.Password, _ = url.User.Password()
	dialer, err := proxy.SOCKS5("tcp", url.Host, proxyAuth, proxy.Direct)
	if err != nil {
		return fmt.Errorf("failed to configure proxy")
	}
	pathtokens := strings.Split(strings.Trim(url.Path, "/"), "/")
	conn, err := dialer.Dial("tcp", pathtokens[0])
	if err != nil {
		return err
	}
	dial := &linkDial{
		url: url,
	}
	return l.handler(dial, info, conn, options, false, false)
}

func (l *linkSOCKS) handler(dial *linkDial, info linkInfo, conn net.Conn, options linkOptions, incoming bool, removed bool) error {
	return l.links.create(
		conn,              // connection
		dial,              // connection URL
		dial.url.String(), // connection name
		info,              // connection info
		incoming,          // not incoming
		false,             // not forced
		options,           // connection options
		removed,
	)
}
