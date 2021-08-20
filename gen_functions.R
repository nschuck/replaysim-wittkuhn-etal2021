se_shadows <- function(x, y, se, ccol='#66666666', border = NA) {
  # adds se shadows to data x
  polygon(c(x, rev(x)), c(y + se, rev(y - se)), col = ccol, border = border)
}

std.error <- function(X, na.rm = TRUE, within = FALSE ) {
  if (within == FALSE) {
    sd(X, na.rm = TRUE)/sqrt(count(X))
  } else {
    sd(X, na.rm = TRUE)/sqrt(count(X))
  }
}

count <- function(x) { 
  length(na.omit(x)) 
} 