# Introduction
compressHybridScaffold_forIrysView.sh is a tool for compressing a BioNano hybrid scaffold output generated by hybrid scaffold function in IrysView. The purpose of this tool is to facilitate the import of the IrysView hybrid scaffold output into the BioNano Access for visual display. It supports both automatic and manual run of hybrid scaffold output.

# Usage
./HS_old_output/compressHybridScaffold_forIrysView.sh --targetFolder <path/to/hybrid/scaffold/output> --outputFolder <path/to/compressFileOutput> --prefix <name_for_output_file> --manual <0/1>

### Options
  -t/--targetFolder  Hybrid scaffold folder for compression (Required)  
  -o/--outputFolder  Output folder (Required)  
  -p/--prefix  Prefix of the output *.tar.gz file  
  -M/--manual  Whether the hybrid scaffold result to be compressed is from manual cut (1) or not (0)  
  -h/--help  Display the help message  
