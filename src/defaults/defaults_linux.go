//go:build linux
// +build linux

package defaults

// Sane defaults for the Linux platform. The "default" options may be
// may be replaced by the running configuration.
func getDefaults() platformDefaultParameters {
	return platformDefaultParameters{
		// Admin
		DefaultAdminListen: "tcp://localhost:9001",

		// Configuration (used for meshctl)
		DefaultConfigFile: "/etc/mesh.conf",

		// Multicast interfaces
		DefaultMulticastInterfaces: []MulticastInterfaceConfig{
			{Regex: ".*", Beacon: true, Listen: true},
		},

		// Network domain
		DefaultNetworkDomain: NetworkDomainConfig{
			Prefix: "fc",
		},

		// TUN
		MaximumIfMTU:  65535,
		DefaultIfMTU:  65535,
		DefaultIfName: "auto",
	}
}
