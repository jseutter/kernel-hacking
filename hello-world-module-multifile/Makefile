TARGET_KERNEL_DIR := ../linux

PWD := $(CURDIR)

all:  
	$(MAKE) -C $(TARGET_KERNEL_DIR) M=$(PWD) modules
clean: 
	$(MAKE) -C $(TARGET_KERNEL_DIR) M=$(PWD) clean

# Define the final module name
obj-m := hello.o

# Instruct how to make the final module
hello-y := hello_fun.o helpers.o
