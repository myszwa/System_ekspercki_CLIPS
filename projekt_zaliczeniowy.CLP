;;;=======================================================
;;;	Projekt z Metod i Narzędzi Sztucznej Inteligencji
;;;	Copyright (C) 2019 Konrad Tarnowski
;;;	CLIPS version 6.3
;;;
;;;		System ekspertski pozwalający okreśić nasz światpogląd religijny.
;;;		Pomysł zaczerpniętny został z plakatów wystawianych przez grupy ewangelizacyjne :)
;;;		Mój model ma 14 możliwości wyboru, tego nie jest on zbytnio skomplikowany.
;;;		Model dopuszczalnych odpowiedzi został podany w załączonym PDF-ie.
;;;			
;;;		Kolejność komend do uruchomienia aplikacji:
;;;		(clear) -> (load) -> (reset) -> (run)
;;;
;;;========================================================


;;;	Definiuję sobie strukturę (podobnie jak w C++) dla leszego zestawienia
;;; informacji o każdym światopoglądzie. Typ multislot pozwala przechowywać
;;; zbiór wartości w polu faktu(obiektu), natomiast slot pozwala tylko jeden dopuszczalny element.
;;; ?NONE jest domyślnym pustym string'iem.
(deftemplate poglad 

	(multislot nazwa
		(type STRING)
		(default ?NONE)
	)

	(multislot istnienie-transcendecji
		(type SYMBOL)
		(allowed-symbols tak nie nie-wiem nie-interesuje-sie n-d)
		(default n-d)
	)
	
	(multislot sens-zycia
		(type SYMBOL)
		(allowed-symbols nie-wiem nie-interesuje-sie roznie doswiadczenie czlowiek brak-sensu naturze n-d)
		(default n-d)
	)
	
	(slot wielu-bogow
		(type SYMBOL)
		(allowed-symbols tak nie n-d)
		(default n-d)
	)
	
	(slot niezalnosc-od-swiata
		(type SYMBOL)
		(allowed-symbols tak nie n-d)
		(default n-d)
	)
	
	(slot zaangazowany-w-swiecie
		(type SYMBOL)
		(allowed-symbols tak nie n-d)
		(default n-d)
	)
	
	(slot swiat-Bog
		(type SYMBOL)
		(allowed-symbols tak nie nie-wiem n-d)
		(default n-d)
	)
	
	(slot swiat-czesciaBoga
		(type SYMBOL)
		(allowed-symbols tak nie nie-wiem n-d)
		(default n-d)
	)
	
	(slot bostwo-Jezusa
		(type SYMBOL)
		(allowed-symbols tak  nie nie-wiem n-d)
		(default n-d)
	)
)

;;; Definjemy baze wiedzy naszeg systemu opieracjąc się o powyższą strukturę.
;;; Z góry zakładam, że w każdym polu będę przechowywac tylko jedną wartość,
;;; którą w dalszych etapach programu będę badać.
(deffacts baza-pogladow
	
	;;; Grupa poglądów nie przejmujących się ani transcendecją, ani sensem egzystencjalnym.
	(poglad (nazwa "Ateizm")
			(istnienie-transcendecji nie)
			(sens-zycia nie-wiem)
	)
	
	(poglad (nazwa "Agnostycyzm")
			(istnienie-transcendecji nie-wiem)
			(sens-zycia nie-wiem)
	)

	(poglad (nazwa "Apateizm")
			(istnienie-transcendecji nie-interesuje-sie)
			(sens-zycia nie-interesuje-sie)
	)
	
	;;; Grupa poglądów przyjmująca istnienie transcendecji.
	(poglad (nazwa "Politeizm")
			(istnienie-transcendecji tak)
			(wielu-bogow tak)
	)
	
	(poglad (nazwa "Panteizm")
			(istnienie-transcendecji tak)
			(wielu-bogow nie)
			(niezalnosc-od-swiata nie)
			(swiat-Bog tak)
	)
	
	(poglad (nazwa "Panenteizm")
			(istnienie-transcendecji tak)
			(wielu-bogow nie)
			(niezalnosc-od-swiata nie)
			(swiat-Bog nie)
			(swiat-czesciaBoga tak)
	)
	
	(poglad (nazwa "Teizm")
			(istnienie-transcendecji tak)
			(wielu-bogow nie)
			(niezalnosc-od-swiata tak)
			(zaangazowany-w-swiecie tak)
			(bostwo-Jezusa nie-wiem)
	)
	
	(poglad (nazwa "Teizm chrzescijanski")
			(istnienie-transcendecji tak)
			(wielu-bogow nie)
			(niezalnosc-od-swiata tak)
			(zaangazowany-w-swiecie tak)
			(bostwo-Jezusa tak)
	)
	
	(poglad (nazwa "Deizm")
			(istnienie-transcendecji tak)
			(wielu-bogow nie)
			(niezalnosc-od-swiata tak)
			(zaangazowany-w-swiecie nie)
	)
	
	;;; Grupa poglądów wynikacjących w sensu życia (nie przejmujących się transcendecją).
	(poglad (nazwa "Relatywizm")
			(istnienie-transcendecji nie nie-wiem nie-interesuje-sie)
			(sens-zycia roznie)
	)
	
	(poglad (nazwa "Egzystencjalizm")
			(istnienie-transcendecji nie nie-wiem nie-interesuje-sie)
			(sens-zycia doswiadczenie)
	)
	
	(poglad (nazwa "Humanizm")
			(istnienie-transcendecji nie nie-wiem nie-interesuje-sie)
			(sens-zycia czlowiek)
	)
	
	(poglad (nazwa "Nihilizm")
			(istnienie-transcendecji nie nie-wiem nie-interesuje-sie)
			(sens-zycia brak-sensu)
	)
	
	(poglad (nazwa "Naturalizm")
			(istnienie-transcendecji nie nie-wiem nie-interesuje-sie)
			(sens-zycia naturze)
	)
)

;;; Zmienna globalna przechowująca aktualną liczbę faktów.
;;;	Jest ona cały czas zmniejszana podczas przechodzenia do
;;; dalszych pytań w programie.
(defglobal ?*licznik* = 14)

;;; Funkcja zmniejsza licznik o 1, przy kazdej operacji eliminacji
;;; faktu (retract) z bazy wiedzy.
(deffunction minusJeden ()
	(bind ?*licznik* (- ?*licznik* 1))
)


;;; Funkcja służąca do zadawania pytań użytkownikowi. Funkcja ta stosuje również
;;; walidację odpowiedzi. Dopóki podajemy coś spoza dopuszczalnej listy odpowiedzi,
;;; dopóty funkcja prosi nas o powtórzenie odpowiedzi.
;;;	$?argumnety - lista cech zgoda ze zdefiniowaną strukturą.
(deffunction pytanie (?tresc $?argumnety)
	(printout t ?tresc)
	(bind ?odpowiedz (read))						; read - pobiera dane ze strumienia wejściowego
	(if (lexemep ?odpowiedz)						; lexemep() sprawdza, czy to typ STRING
		then (bind ?odpowiedz (lowcase ?odpowiedz))	; lowcase() zmienia litery na małe 
	)
	(while (not (member ?odpowiedz ?argumnety)) do	; member() zwraca FAŁSZ jeśli wartości nie ma w liście argumnetów
		(printout t ?tresc)
		(bind ?odpowiedz (read))
		(if (lexemep ?odpowiedz)
			then (bind ?odpowiedz (lowcase ?odpowiedz))	
		)
	)
	?odpowiedz
)

;;; Jest to pierwsze pytanie zadawane użytkownikowi. Rezultat jest zapisany w formie 
;;; nowoutworzonego faktu (poWierze).
;;;	assert () - dodajemy fakt do pamięci programu.
;;; retract() - wycofujemy fakt z pamięci progrmau.
;;; initial-fact to wartość nadawana podczas uruchomienia komendy (reset).
;;; Wyzwalacz jest uruchamiany na skutek obecności tego faktu w pamięci.
(defrule pytanie-wiara
	?x <- (initial-fact)
	=>
	(retract ?x)
	(bind ?odp (pytanie "###Czy Bog istnieje? (tak, nie, nie-wiem, nie-interesuje-sie)### " tak nie nie-wiem nie-interesuje-sie))
	(assert (poWierze ?odp))
)

;;; Otrzymany wynik użytkownika w postaci faktu musimy wykorzystać do usunięcia
;;; niepotrzebnych faktów z bazy wiedzy. Przy każdym usunięciu faktu, uruchamiana
;;; jest funkcja minusJeden().
(defrule filtruj-poWierze
	(poWierze ?w)
	?fakt <- (poglad (istnienie-transcendecji $?x))
	=>
	(if (not (member$ ?w $?x))
		then (retract ?fakt) (minusJeden)
	)
)

;;; Po pytaniu ogólnym musimy wybrać kierunek nastepnych pytań. Reguła ta jest potrzebana
;;; o tyle, że nie możemy umieści assert() w powyższej regule :/
;;; neq - jeśli dwie wartości nie są równe, zwróć PRAWDA
(defrule poWierze
	?x <- (poWierze ?odp)
	=>
	(retract ?x)
	(if (neq ?odp tak)
		then (assert (zapytaj oSensZycia))
		else (assert (zapytaj oBoga))
	)
)

;;; Pytanie dostępne po wybraniu czegoś innego niż TAK.
(defrule pytanie-sens
	?x <- (zapytaj ?y)
	(test (eq ?y oSensZycia))
	=>
	(retract ?x)
	(printout t "###Gdzie znajdujsz sens zycia?" crlf)	; informacja dla użytkownika nie mieści się w jednej linijce
	(bind ?odp (pytanie "(nie-wiem, nie-interesuje-sie, roznie, doswiadczenie, czlowiek, brak-sensu, naturze)### " nie-wiem nie-interesuje-sie roznie doswiadczenie czlowiek brak-sensu naturze))
	(assert (poSensie ?odp))
)

;;; Usuwamy wszystkie niepasujące fakty do powyższego pytania zostawiając tylko te, kótre pasują.
(defrule filtruj-poSensie
	(poSensie ?s)
	?fakt <- (poglad (sens-zycia $?x))
	=>
	(if (not (member$ ?s $?x))
		then (retract ?fakt) (minusJeden)
	)
)

;;; Wybieramy pomiędzy ateizmem a apateizmem
(defrule poSensie
	(poSensie ?s)
	(test (eq ?s nie-wiem))
	?p1 <- (poglad (istnienie-transcendecji ?x1))
	?p2 <- (poglad (istnienie-transcendecji ?x2))
	(test (neq ?p1 ?p2))
	=>
	(if (eq ?x1 nie)					; jeśli ateizmeme jest ?x1 ...
		then (retract ?p1) (minusJeden)
		else (retract ?p2) (minusJeden)
	)
)

;;; Jesli ktoś w pytaniu o Boga wybrał TAK, następuje
;;; przekierowanie do kategorii pytań o obraz transcendecji
(defrule pytanie-monoteizm
	?x <- (zapytaj ?y)
	(test (eq ?y oBoga))
	=>
	(retract ?x)
	(bind ?odp (pytanie "###Czy istnieje wielu bogow? (tak, nie)### " tak nie))
	(assert (poMonoteizmie ?odp))
)

(defrule filtruj-poMonoteizmie
	(poMonoteizmie ?m)
	?fakt <- (poglad (wielu-bogow ?x))
	=>
	(if (neq ?m ?x)						; wyrzcamy fakty niespełniające naszego atrybutu
		then (retract ?fakt) (minusJeden)
	)
)

(defrule poMonoteizmie
	?x <- (poMonoteizmie ?odp)
	=>
	(retract ?x)
	(if (eq ?odp nie)
		then (assert (zapytaj oNiezaleznosc))
	)
)

;;; Mamy tu trzy możliwe odpowiedzi. Jeśli padanie odpowiedź NIE, to wskazujemy na deizm.
;;; Jeśli padnie odpowiedz TAK, to wywłujemy następne zapytanie, jednocześnie usuwając te aktualne.
(defrule pytanie-niezaleznosc
	?x <- (zapytaj ?y)
	(test(eq ?y oNiezaleznosc))
	=>
	(retract ?x)
	(bind ?odp (pytanie "###Czy Bog istnieje niezaleznie od swiata? (tak, nie)### " tak nie))
	(assert (poNiezaleznosci ?odp))
)

(defrule filtruj-poNiezaleznosci
	(poNiezaleznosci ?odp)
	?fakt <- (poglad (niezalnosc-od-swiata ?x))
	=>
	(if (neq ?odp ?x)
		then (retract ?fakt) (minusJeden)
	)
)

(defrule poNiezaleznosci
	?x <- (poNiezaleznosci ?odp)
	=>
	(retract ?x)
	(if (eq ?odp tak)
		then (assert (zapytaj oZaangazowanie))
		else (assert (zapytaj oWszechobecnosc))
	)
)

;;; Jeżeli użytkownik na pytanie o niezależność wybrał TAK, 
;;; przechodzi do poniższego pytania.
(defrule pytanie-zaagazowanie
	?x <- (zapytaj ?y)
	(test (eq ?y oZaangazowanie))
	=>
	(retract ?x)
	(bind ?odp (pytanie "###Czy Bog jest zaangazowany w dzieje swiata? (tak, nie)### " tak nie ))
	(assert (poZaangazowaniu ?odp))
)

(defrule filtruj-poZaangazowaniu
	(poZaangazowaniu ?odp)
	?fakt <- (poglad (zaangazowany-w-swiecie ?x))
	=>
	(if (neq ?odp ?x)
		then (retract ?fakt) (minusJeden)
	)
)

(defrule poZaangazowaniu
	?x <- (poZaangazowaniu ?odp)
	=>
	(retract ?x)
	(if (eq ?odp tak)
		then (assert(zapytaj oJezusa))
	)
)

;;; Jeśli użytkownik w pytaniu o ingerencję w dzieję świata odpowiedział TAK,
;;; przechodzi do poniższego pytania. Mamy tu trzy możliwości.
(defrule pytanie-Jezus
	?z <- (zapytaj ?y)
	(test (eq ?y oJezusa))
	?p1 <- (poglad (bostwo-Jezusa ?x1))
	?p2 <- (poglad (bostwo-Jezusa ?x2))
	(test (neq ?p1 ?p2))
	=>
	(retract ?z)
	(bind ?odp (pytanie "###Czy Bog objawil sie w Jezusie Chrystusie? (tak, nie, nie-wiem)### " tak nie nie-wiem ))
	(if (eq ?odp ?x1)
		then (retract ?p2) (minusJeden)
	)
	(if (eq ?odp ?x2)
		then (retract ?p1) (minusJeden)
	)
	(if (neq ?*licznik* 1)
		then (assert (znaleziono falsz))
	)
)

;;; Jeśli użytkownik uznał zależność Boga od świata, została uruchomiona ta reguła.
;;; Mamy tutaj trzy możliwości odpowiedzi. nie-wiem prowadzi o niedopasowania reguły.
(defrule pytanie-wszechobecnosc
	?z <- (zapytaj ?y)
	(test (eq ?y oWszechobecnosc))
	?p1 <- (poglad (swiat-Bog ?x1))
	?p2 <- (poglad (swiat-Bog ?x2))
	(test (neq ?p1 ?p2))
	=>
	(retract ?z)
	(bind ?odp (pytanie "###Czy bezosobowy swiat ktory widzsz jest Bogiem? (tak, nie, nie-wiem)### " tak nie nie-wiem))
	(if (eq ?odp nie-wiem)
		then (retract ?p1 ?p2) (assert (znaleziono falsz))
	)
	(if (eq ?odp nie)
		then (assert (poOsobowosci ?odp))
	)
	(if (and (eq ?odp ?x1) (eq ?x1 tak))
		then (retract ?p2) (minusJeden)
	)
	(if (and (eq ?odp ?x2) (eq ?x2 tak))
		then (retract ?p1) (minusJeden)
	)
)

(defrule pytania-osobowosc
	?z <- (poOsobowosci ?y)
	(test (eq ?y nie))
	?p1 <- (poglad (swiat-Bog ?x1))
	?p2 <- (poglad (swiat-Bog ?x2))
	(test (neq ?p1 ?p2))
	=>
	(retract ?z)
	(bind ?odp (pytanie "###Czy Bog zawiera w sobie caly swiat, ale go nie wyczepuje? (tak, nie, nie-wiem)### " tak nie nie-wiem))
	(if (neq ?odp tak)
		then (retract ?p1 ?p2) (assert (znaleziono falsz))
		else (assert (znaleziono prawda))
	)
)

;;; Reguła kontroluje ilość faktów 
(defrule wgLiczbyFaktow
	=>
	(if (eq ?*licznik* 1)
		then (assert (znaleziono prawda))
	)
	(if (eq ?*licznik* 0)
		then (assert (znaleziono falsz))
	)
)

;;; Jeśli dopasowaliśmy fakt (znaleziono prawda) to znaczy że został tylko jednen fakt w pamięci programu.
;;; Przekopiowujemy informacje o pogladzie do zmiennych i usuwamy ostatni fakt.
(defrule pogladZnaleziony
	?z <- (znaleziono prawda)
	?idea <- (poglad (nazwa ?n))
	=>
	(retract ?z ?idea)
	(printout t "*********************" crlf)
	(printout t "Twoj poglad to: " crlf)
	(printout t "Nazwa: " ?n crlf)
	(printout t "*********************" crlf)
)

;;; Jeśli nie dopasowaliśmy żandego faktu, to znaczy że w pamięci programu nie ma już żadnego faktu.
(defrule pogladNieZnaleziony
	?z <- (znaleziono falsz)
	=>
	(retract ?z)
	(printout t "*********************" crlf)
	(printout t "Niesety nie znalaziono dopasowania" crlf)
	(printout t "*********************" crlf)
)