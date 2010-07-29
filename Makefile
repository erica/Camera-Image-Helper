# e.g. make git COMMIT="Chapter 8 Images"
git:
	git add -A *
	git commit -m '$(COMMIT)'
	git push

clean:
	rm -rf */*/build

sync:
	cp *.[hm] ~/Desktop/11-New\ Edition\ Sample\ Code/01-Essential\ Recipes/C07-Images/99-Live\ Input\ Buffer

