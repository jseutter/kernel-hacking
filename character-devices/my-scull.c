#include <linux/module.h>
#include <linux/kernel.h>

static int __init my_module_init(void)
{
	pr_info("My In-Tree Module: Loaded!");
    return 0;
}

static void __exit my_module_exit(void)
{
	pr_info("My In-Tree Module: Unloaded!");
}

module_init(my_module_init);
module_exit(my_module_exit);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Jerry Seutter");
MODULE_DESCRIPTION("A minimal example for in-tree kernel hacking.");
MODULE_VERSION("0.1");

