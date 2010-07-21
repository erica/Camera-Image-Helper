# e.g. make git COMMIT="Chapter 8 Images"
git:
	git add -A *
	git commit -m '$(COMMIT)'
	git push

clean:
	rm -rf */*/build
