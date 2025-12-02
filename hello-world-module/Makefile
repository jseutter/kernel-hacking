#obj-m += hello-1.o
obj-m += hello-2.o

TARGET_KERNEL_DIR := ../linux

PWD := $(CURDIR)

all:  
	$(MAKE) -C $(TARGET_KERNEL_DIR) M=$(PWD) modules
clean: 
	$(MAKE) -C $(TARGET_KERNEL_DIR) M=$(PWD) clean
