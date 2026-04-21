FROM alpine:3.21

RUN apk add --no-cache \
    texlive \
    texlive-luatex \
    texlive-most \
    biber \
    py3-pygments \
    poppler-utils \
    rsvg-convert \
    font-dejavu \
    make \
    python3 \
    py3-pip \
    py3-numpy \
    py3-scipy \
    py3-pandas \
    py3-statsmodels \
    py3-matplotlib

WORKDIR /paper
CMD ["latexmk", "-pdf", "-interaction=nonstopmode", "-halt-on-error", "main.tex"]
