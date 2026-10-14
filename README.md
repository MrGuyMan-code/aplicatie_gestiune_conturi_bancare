# Aplicatie pentru gestiunea operațiunilor privind clienții unei bănci

## Descriere

Acest proiect constă într-o aplicație pentru gestiunea operațiunilor privind clienții unei bănci, realizată ca prototip la scară redusă al unui sistem financiar real. Aplicația se adresează domeniului bancar și urmărește înțelegerea și însușirea procedeelor și standardelor utilizate în acest tip de software.

## Funcționalități

Aplicația pune la dispoziția clienților operațiunile bancare esențiale, precum depunerea de bani și transferul între conturi, oferind totodată posibilitatea generării unui extras de cont pentru urmărirea situației financiare.

## Operații

Operațiile sunt realizate cu ajutorul unui jurnal de tip ledger, menit să asigure consistența datelor și trasabilitatea fiecărei acțiuni. Pentru o eventuală extindere, se are în vedere implementarea unui sistem de snapshot-uri, care să crească viteza de acces la date.

## Utilizatori

Aplicația va fi utilizată de mai multe tipuri de utilizatori, de la clienți până la administratori, aplicându-se principiul minimei permisiuni posibile (least privilege), astfel încât fiecare utilizator să aibă acces doar la resursele strict necesare rolului său.