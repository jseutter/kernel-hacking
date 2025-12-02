/* Note: This is an older way to initialize a module.  Look at module_init in hello-2.c for a modern pattern. */
#include <linux/module.h>
#include <linux/printk.h>
 
  
static int module_init(void)  
{  
    pr_info("Hello world 1.\n");  
    return 0;  
}  


void module_cleanup(void)  
{  
    pr_info("Goodbye world 1.\n");  
}
 

MODULE_LICENSE("GPL");

