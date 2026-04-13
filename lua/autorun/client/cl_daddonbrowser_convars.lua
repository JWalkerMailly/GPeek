
CreateClientConVar("gpeek_batch_size", "10", true, false, "Number of files to process per batch.", 1, 100)
CreateClientConVar("gpeek_batch_delay", "0", true, false, "Processing delay between each file batch.", 0, 1)
CreateClientConVar("gpeek_multi_addon", "0", true, false, "Allow expanding multiple addons.", 0, 1)

CreateClientConVar("gpeek_background_r", "0", true, false, "Background color 'red' component.",   0, 255)
CreateClientConVar("gpeek_background_g", "0", true, false, "Background color 'green' component.", 0, 255)
CreateClientConVar("gpeek_background_b", "0", true, false, "Background color 'blue' component.",  0, 255)