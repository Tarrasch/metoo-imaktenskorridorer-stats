Sammanställningen nedan är verkligen work in progress. Alltså se siffrorna som ungerfärliga!

## Sammanfattning

Jag tog aftonbladets [lista med
1641](https://www.aftonbladet.se/nyheter/a/0Ej4x2/har-ar-alla-1-641-namn-som-skrivit-under-imaktenskorridorer)
tweets om [#imaktenskorridorer](https://twitter.com/hashtag/iMaktensKorridorer)
och ville se om jag kunde få lite statistik korrelerat till parti. 

Jag räknar in ungdomspartier.

## Commands

Siffrorna får jag fram som nedan.

```
cat data.txt | sort --unique | stack Main.hs | sort | uniq --count | sort --numeric-sort 
     17 KD
     79 FI
    142 L
    145 C
    145 V
    184 MP
    252 M
    577 S
```

Notera att SD egentligen ska vara med med 0 metoo-tweets.
Jag vet ej varför SD har 0 (dåligt hämtad data, tystnadskultur etc.).
