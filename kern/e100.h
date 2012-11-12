#ifndef JOS_KERN_E100_H
#define JOS_KERN_E100_H
#include <inc/types.h>
#include <kern/pci.h>
#define PCI_VENDOR_ID_INTEL 0x8086
#define INTEL_82559_ETHERNET_DEVICE_ID 0x1209

int pci_e100_attach(struct pci_func *pcif);
#endif	// JOS_KERN_E100_H
