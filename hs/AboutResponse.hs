{-# LANGUAGE OverloadedStrings #-}

module AboutResponse where

import           Text.Blaze ((!))
import qualified Text.Blaze.Html5 as H
import qualified Text.Blaze.Html5.Attributes as A
import Data.Text.Lazy (Text)
import Text.Markdown (markdown, def)
import Happstack.Server
import MakeElements
import MasterTemplate

aboutResponse :: Text -> ServerPart Response
aboutResponse aboutContents =
   ok $ toResponse $
    masterTemplate "Courseography - About"
                [H.meta ! A.name "keywords"
                        ! A.content "",
                 aboutLinks
                ]
                (do
                    header "about"
                    aboutHtml aboutContents
                )
                ""

-- | AboutHtml takes in the contents of the README.md file (the GitHub README file) and translates
-- the markdown to blaze-HTML.
aboutHtml :: Text -> H.Html
aboutHtml contents = H.div ! A.id "aboutDiv" $ mdToHTML contents

-- | mdToHTML takes in the contents of a file written in Mark Down and converts it to 
-- blaze-HTML.
mdToHTML :: Text -> H.Html
mdToHTML contents = markdown def contents

