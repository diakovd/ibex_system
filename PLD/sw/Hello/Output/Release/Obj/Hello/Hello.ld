MEMORY
{
  UNPLACED_SECTIONS (wx) : ORIGIN = 0x100000000, LENGTH = 0
  UARTmem (wx) : ORIGIN = 0x00020000, LENGTH = 0x00020000
  UARTio (wx) : ORIGIN = 0x00010004, LENGTH = 0x00000008
  IOmem (wx) : ORIGIN = 0x00010000, LENGTH = 0x00000004
  RAM1 (wx) : ORIGIN = 0x00001000, LENGTH = 0x00001000
  FLASH1 (wx) : ORIGIN = 0x00000000, LENGTH = 0x00001000
}

SECTIONS
{
  __UARTmem_segment_start__ = 0x00020000;
  __UARTmem_segment_end__ = 0x00040000;
  __UARTmem_segment_size__ = 0x00020000;
  __UARTio_segment_start__ = 0x00010004;
  __UARTio_segment_end__ = 0x0001000c;
  __UARTio_segment_size__ = 0x00000008;
  __IOmem_segment_start__ = 0x00010000;
  __IOmem_segment_end__ = 0x00010004;
  __IOmem_segment_size__ = 0x00000004;
  __RAM1_segment_start__ = 0x00001000;
  __RAM1_segment_end__ = 0x00002000;
  __RAM1_segment_size__ = 0x00001000;
  __FLASH1_segment_start__ = 0x00000000;
  __FLASH1_segment_end__ = 0x00001000;
  __FLASH1_segment_size__ = 0x00001000;

  __HEAPSIZE__ = 1024;
  __STACKSIZE__ = 1024;

  __vectors_load_start__ = __FLASH1_segment_start__;
  .vectors __FLASH1_segment_start__ : AT(__FLASH1_segment_start__)
  {
    __vectors_start__ = .;
    *(.vectors .vectors.*)
  }
  __vectors_end__ = __vectors_start__ + SIZEOF(.vectors);
  __vectors_size__ = SIZEOF(.vectors);
  __vectors_load_end__ = __vectors_end__;

  __init_load_start__ = ALIGN(__vectors_end__ , 4);
  .init ALIGN(__vectors_end__ , 4) : AT(ALIGN(__vectors_end__ , 4))
  {
    __init_start__ = .;
    *(.init .init.*)
  }
  __init_end__ = __init_start__ + SIZEOF(.init);
  __init_size__ = SIZEOF(.init);
  __init_load_end__ = __init_end__;

  __init_rodata_load_start__ = ALIGN(__init_end__ , 4);
  .init_rodata ALIGN(__init_end__ , 4) : AT(ALIGN(__init_end__ , 4))
  {
    __init_rodata_start__ = .;
    *(.init_rodata .init_rodata.*)
  }
  __init_rodata_end__ = __init_rodata_start__ + SIZEOF(.init_rodata);
  __init_rodata_size__ = SIZEOF(.init_rodata);
  __init_rodata_load_end__ = __init_rodata_end__;

  __text_load_start__ = ALIGN(__init_rodata_end__ , 4);
  .text ALIGN(__init_rodata_end__ , 4) : AT(ALIGN(__init_rodata_end__ , 4))
  {
    __text_start__ = .;
    *(.text .text.* .glue_7t .glue_7 .gnu.linkonce.t.* .gcc_except_table .ARM.extab* .gnu.linkonce.armextab.*)
  }
  __text_end__ = __text_start__ + SIZEOF(.text);
  __text_size__ = SIZEOF(.text);
  __text_load_end__ = __text_end__;

  __dtors_load_start__ = ALIGN(__text_end__ , 4);
  .dtors ALIGN(__text_end__ , 4) : AT(ALIGN(__text_end__ , 4))
  {
    __dtors_start__ = .;
    KEEP (*(SORT(.dtors.*))) KEEP (*(.dtors)) KEEP (*(.fini_array)) KEEP (*(SORT(.fini_array.*)))
  }
  __dtors_end__ = __dtors_start__ + SIZEOF(.dtors);
  __dtors_size__ = SIZEOF(.dtors);
  __dtors_load_end__ = __dtors_end__;

  __ctors_load_start__ = ALIGN(__dtors_end__ , 4);
  .ctors ALIGN(__dtors_end__ , 4) : AT(ALIGN(__dtors_end__ , 4))
  {
    __ctors_start__ = .;
    KEEP (*(SORT(.ctors.*))) KEEP (*(.ctors)) KEEP (*(.init_array)) KEEP (*(SORT(.init_array.*)))
  }
  __ctors_end__ = __ctors_start__ + SIZEOF(.ctors);
  __ctors_size__ = SIZEOF(.ctors);
  __ctors_load_end__ = __ctors_end__;

  __rodata_load_start__ = ALIGN(__ctors_end__ , 4);
  .rodata ALIGN(__ctors_end__ , 4) : AT(ALIGN(__ctors_end__ , 4))
  {
    __rodata_start__ = .;
    *(.rodata .rodata.* .gnu.linkonce.r.*)
  }
  __rodata_end__ = __rodata_start__ + SIZEOF(.rodata);
  __rodata_size__ = SIZEOF(.rodata);
  __rodata_load_end__ = __rodata_end__;

  __srodata_load_start__ = ALIGN(__rodata_end__ , 4);
  .srodata ALIGN(__rodata_end__ , 4) : AT(ALIGN(__rodata_end__ , 4))
  {
    __srodata_start__ = .;
    *(.srodata .srodata.*)
  }
  __srodata_end__ = __srodata_start__ + SIZEOF(.srodata);
  __srodata_size__ = SIZEOF(.srodata);
  __srodata_load_end__ = __srodata_end__;

  __eh_frame_load_start__ = ALIGN(__srodata_end__ , 4);
  .eh_frame ALIGN(__srodata_end__ , 4) : AT(ALIGN(__srodata_end__ , 4))
  {
    __eh_frame_start__ = .;
    KEEP(*(.eh_frame .eh_frame.*))
  }
  __eh_frame_end__ = __eh_frame_start__ + SIZEOF(.eh_frame);
  __eh_frame_size__ = SIZEOF(.eh_frame);
  __eh_frame_load_end__ = __eh_frame_end__;

  __gcc_except_table_load_start__ = ALIGN(__eh_frame_end__ , 4);
  .gcc_except_table ALIGN(__eh_frame_end__ , 4) : AT(ALIGN(__eh_frame_end__ , 4))
  {
    __gcc_except_table_start__ = .;
    *(.gcc_except_table .gcc_except_table.*)
  }
  __gcc_except_table_end__ = __gcc_except_table_start__ + SIZEOF(.gcc_except_table);
  __gcc_except_table_size__ = SIZEOF(.gcc_except_table);
  __gcc_except_table_load_end__ = __gcc_except_table_end__;

  __data_load_start__ = ALIGN(__gcc_except_table_end__ , 4);
  .data ALIGN(__RAM1_segment_start__ , 4) : AT(ALIGN(__gcc_except_table_end__ , 4))
  {
    __data_start__ = .;
    *(.data .data.* .gnu.linkonce.d.*)
  }
  __data_end__ = __data_start__ + SIZEOF(.data);
  __data_size__ = SIZEOF(.data);
  __data_load_end__ = __data_load_start__ + SIZEOF(.data);

  .data_run ALIGN(__RAM1_segment_start__ , 4) (NOLOAD) :
  {
    __data_run_start__ = .;
    . = MAX(__data_run_start__ + SIZEOF(.data), .);
  }
  __data_run_end__ = __data_run_start__ + SIZEOF(.data_run);
  __data_run_size__ = SIZEOF(.data_run);
  __data_run_load_end__ = __data_run_end__;

  __tdata_load_start__ = ALIGN(__data_load_start__ + SIZEOF(.data) , 4);
  .tdata ALIGN(__data_run_end__ , 4) : AT(ALIGN(__data_load_start__ + SIZEOF(.data) , 4))
  {
    __tdata_start__ = .;
    *(.tdata .tdata.*)
  }
  __tdata_end__ = __tdata_start__ + SIZEOF(.tdata);
  __tdata_size__ = SIZEOF(.tdata);
  __tdata_load_end__ = __tdata_load_start__ + SIZEOF(.tdata);

  .tdata_run ALIGN(__data_run_end__ , 4) (NOLOAD) :
  {
    __tdata_run_start__ = .;
    . = MAX(__tdata_run_start__ + SIZEOF(.tdata), .);
  }
  __tdata_run_end__ = __tdata_run_start__ + SIZEOF(.tdata_run);
  __tdata_run_size__ = SIZEOF(.tdata_run);
  __tdata_run_load_end__ = __tdata_run_end__;

  __bss_load_start__ = ALIGN(__tdata_run_end__ , 4);
  .bss ALIGN(__tdata_run_end__ , 4) (NOLOAD) : AT(ALIGN(__tdata_run_end__ , 4))
  {
    __bss_start__ = .;
    *(.bss .bss.* .gnu.linkonce.b.*) *(COMMON)
  }
  __bss_end__ = __bss_start__ + SIZEOF(.bss);
  __bss_size__ = SIZEOF(.bss);
  __bss_load_end__ = __bss_end__;

  __tbss_load_start__ = ALIGN(__bss_end__ , 4);
  .tbss ALIGN(__bss_end__ , 4) (NOLOAD) : AT(ALIGN(__bss_end__ , 4))
  {
    __tbss_start__ = .;
    *(.tbss .tbss.*)
  }
  __tbss_end__ = __tbss_start__ + SIZEOF(.tbss);
  __tbss_size__ = SIZEOF(.tbss);
  __tbss_load_end__ = __tbss_end__;

  __sdata_load_start__ = ALIGN(__tdata_load_start__ + SIZEOF(.tdata) , 4);
  .sdata ALIGN(__tbss_end__ , 4) : AT(ALIGN(__tdata_load_start__ + SIZEOF(.tdata) , 4))
  {
    __sdata_start__ = .;
    *(.sdata.* .sdata2.*)
  }
  __sdata_end__ = __sdata_start__ + SIZEOF(.sdata);
  __sdata_size__ = SIZEOF(.sdata);
  __sdata_load_end__ = __sdata_load_start__ + SIZEOF(.sdata);

  __FLASH1_segment_used_end__ = ALIGN(__tdata_load_start__ + SIZEOF(.tdata) , 4) + SIZEOF(.sdata);
  __FLASH1_segment_used_size__ = __FLASH1_segment_used_end__ - __FLASH1_segment_start__;

  .sdata_run ALIGN(__tbss_end__ , 4) (NOLOAD) :
  {
    __sdata_run_start__ = .;
    . = MAX(__sdata_run_start__ + SIZEOF(.sdata), .);
  }
  __sdata_run_end__ = __sdata_run_start__ + SIZEOF(.sdata_run);
  __sdata_run_size__ = SIZEOF(.sdata_run);
  __sdata_run_load_end__ = __sdata_run_end__;

  __sbss_load_start__ = ALIGN(__sdata_run_end__ , 4);
  .sbss ALIGN(__sdata_run_end__ , 4) (NOLOAD) : AT(ALIGN(__sdata_run_end__ , 4))
  {
    __sbss_start__ = .;
    *(.sbss .sbss.*)
  }
  __sbss_end__ = __sbss_start__ + SIZEOF(.sbss);
  __sbss_size__ = SIZEOF(.sbss);
  __sbss_load_end__ = __sbss_end__;

  __non_init_load_start__ = ALIGN(__sbss_end__ , 4);
  .non_init ALIGN(__sbss_end__ , 4) (NOLOAD) : AT(ALIGN(__sbss_end__ , 4))
  {
    __non_init_start__ = .;
    *(.non_init .non_init.*)
  }
  __non_init_end__ = __non_init_start__ + SIZEOF(.non_init);
  __non_init_size__ = SIZEOF(.non_init);
  __non_init_load_end__ = __non_init_end__;

  __heap_load_start__ = ALIGN(__non_init_end__ , 4);
  .heap ALIGN(__non_init_end__ , 4) (NOLOAD) : AT(ALIGN(__non_init_end__ , 4))
  {
    __heap_start__ = .;
    *(.heap .heap.*)
    . = ALIGN(MAX(__heap_start__ + __HEAPSIZE__ , .), 4);
  }
  __heap_end__ = __heap_start__ + SIZEOF(.heap);
  __heap_size__ = SIZEOF(.heap);
  __heap_load_end__ = __heap_end__;

  __stack_load_start__ = __RAM1_segment_start__ + (__RAM1_segment_size__ - 1024);
  .stack __RAM1_segment_start__ + (__RAM1_segment_size__ - 1024) (NOLOAD) : AT(__RAM1_segment_start__ + (__RAM1_segment_size__ - 1024))
  {
    __stack_start__ = .;
    *(.stack .stack.*)
    . = ALIGN(MAX(__stack_start__ + __STACKSIZE__ , .), 4);
  }
  __stack_end__ = __stack_start__ + SIZEOF(.stack);
  __stack_size__ = SIZEOF(.stack);
  __stack_load_end__ = __stack_end__;

  __RAM1_segment_used_end__ = __RAM1_segment_start__ + (__RAM1_segment_size__ - 1024) + SIZEOF(.stack);
  __RAM1_segment_used_size__ = __RAM1_segment_used_end__ - __RAM1_segment_start__;

}

