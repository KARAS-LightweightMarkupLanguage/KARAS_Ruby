
# Copyright (c) 2014, Daiki Umeda (XJINE) - lightweightmarkuplanguage.com
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# 
# * Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
# 
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
# 
# * Neither the name of the copyright holder nor the names of its
#   contributors may be used to endorse or promote products derived from
#   this software without specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

class TOC
    def self.action(options, markedupText, text)
        # Remove heading syntax in pre element.
        tempText = String.new(text)
        tempText = KARAS::replaceTextInPreElement(tempText, "=", "")

        # match group index.
        mgiAllText = 0
        mgiMarks = 1
        mgiMarkedupText = 2
        mgiBreaks = 3

        topLevel = 1
        bottomLevel = 6

        if options.length > 0
            topLevel = options[0].to_i()
        end

        if options.length > 1
            bottomLevel = options[1].to_i()
        end

        newText = ""
        previousLevel = 0
        match = nil
        nextMatchIndex = 0

        while true
            match = KARAS::RegexHeading.match(tempText, nextMatchIndex)

            if match == nil
                previousLevel.times do
                    newText += "</li>\n</ul>\n"
                end

                break
            end

            if match[mgiMarks].length <= bottomLevel
                level = match[mgiMarks].length
                level = level - topLevel + 1

                if level > 0
                    levelDiff = level - previousLevel
                    previousLevel = level

                    if levelDiff > 0
                        levelDiff.times do
                            newText += "\n<ul>\n<li>"
                        end
                    elsif levelDiff < 0
                        levelDiff *= -1
                        levelDiff.times do
                            newText += "</li>\n</ul>\n"
                        end

                        newText += "<li>"
                    else
                        newText += "</li>\n<li>"
                    end

                    markedupText = KARAS.convertInlineMarkup(match[mgiMarkedupText])
                    hasSpecialOption = false
                    markedupTexts, hasSpecialOption = KARAS.splitOptions(markedupText, hasSpecialOption)
                    itemText = markedupTexts[0]

                    if markedupTexts.length > 1
                        itemText = "<a href=\"#" + markedupTexts[1].strip() + "\">" +
                                   itemText +
                                   "</a>"
                    end

                    newText += itemText
                end
            end

            nextMatchIndex = match.begin(mgiAllText) +
                             match[mgiAllText].length -
                             match[mgiBreaks].length
        end

        return newText.strip()
    end
end
