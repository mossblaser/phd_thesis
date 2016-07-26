BEGIN{
	figures=0
}

/\\begin\{figure\}/{
	subfigs=0
}

/\\begin\{subfigure\}/{
	subfigs++
}

/\\end\{figure\}/{
	if (subfigs == 0)
		figures += 1;
	else
		figures += subfigs;
}

END{
	print figures
}
