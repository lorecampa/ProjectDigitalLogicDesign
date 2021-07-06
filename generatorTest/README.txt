Mettere in setUp.txt il numero di test da generare e il massimo numero
che si vuole nella dimesione dell'immagine.
Copiare e incollare tutto il codice di LauncherDaVHDL.txt in vivado in un file si simulazione
mettere il proprio percorso dei file a questa cartella! [riferimenti: DatiTest_Ram, passati, non_passati]
Far partire la sintesi o la simulazione, aspettare la fine e fare RunAll, attendere parecchio! :)
[10000	64]	circa 40 secondi
[2000 	128]	circa 5 minuti
[2000 	80]	circa 3 mituit e 30
Al termine dell'esecuzione troverai nei file passato i casi che hai superato con successo
nel file non_passato la lista dei non passati o "Tutti i test sono stati passati!"

ESEMPIO SetUp.txt:
1000 100 
//SONO 1000 IMMAGINI DA MASSIMO 100x100(numero varibile di righe e colonne fino al valore scritto)