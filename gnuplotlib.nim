import os

type
  Plot = object
    beforeStyle*, beforeStyleVar*, afterStyleVar*, afterStyle*, beforeHeader*, extra*, afterHeader*, bp*: string
    terminal*, output*: string
