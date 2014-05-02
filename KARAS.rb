
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

#Need Ruby Version 1.9 or later.

module KARAS extend self
    #Block group
    RegexBlockGroup =
        Regexp.new("^(?:(\{\{)(.*?)|\}\}.*?)$")
    RegexFigcaptionSummary = 
        Regexp.new("(?:^|\n)(\=+)(.*?)(\n(?:(?:(?:\\||\!)[\\|\=\>\<]|\=|\-|\\+|\;|\>|\<)|\n)|$)",
                   Regexp::MULTILINE)

    #Block markup
    RegexBlockquote = 
        Regexp.new("(?:\\A|\n)(\\>+)(.*?)(?:(\n\>)" +
                   "|(\n(?:\n|\=|\-|\\+|\;|(?:(?:\\||\!)[\\|\=\>\<])))|\\z)",
                    Regexp::MULTILINE)
    RegexTableBlock =
        Regexp.new("(?:\\A|\n)((?:\\||\!)(?:\\||\>|\<|\=).*?)" +
                   "(\n(?!(?:\\||\!)[\\|\=\>\<])|\\z)",
                   Regexp::MULTILINE)
    RegexTableCell = 
        Regexp.new("(\\\\*)(\\||\!)(\\||\>|\<|\=)", Regexp::MULTILINE)
    RegexList = 
        Regexp.new("(?:\\A|\n)((?:\-|\\+)+)(.*?)(?:(\n(?:\-|\\+))|(\n(?:\n|\;|\=))|\\z)",
                   Regexp::MULTILINE)
    RegexDefList = 
        Regexp.new("(?:\\A|\n)(\;+)(.*?)(?:(\n\;)|(\n(?:\n|\=))|\\z)", Regexp::MULTILINE)
    RegexHeading = 
        Regexp.new("(?:\\A|\n)(\=+)(.*?)(\n\=|\n{2,}|\\z)", Regexp::MULTILINE)
    #It is important to check '\n{2,}' first, to exclude \n chars.
    RegexBlockLink = 
        Regexp.new("(?:\n{2,}|\\A\n*)\\s*\\({2,}.+?(?:\n{2,}|\\z)", Regexp::MULTILINE)
    RegexParagraph = 
        Regexp.new("(?:\n{2,}|\\A\n*)(\\s*(<*).+?)(?:\n{2,}|\\z)", Regexp::MULTILINE)

    #Inline markup
    RegexInlineMarkup = 
        Regexp.new("(\\\\*)(\\*{2,}|/{2,}|_{2,}|%{2,}|\\@{2,}" + 
                   "|\\?{2,}|\\${2,}|`{2,}|'{2,}|,{2,}|\"{2,}" + 
                   "|\\({2,}[\t\v\f\u0020\u00A0]*\\(*|\\){2,}[\t\v\f\u0020\u00A0]*\\)*" +
                   "|<{2,}[\u0020\u00A0]*<*|>{2,}[\u0020\u00A0]*>*)",
                    Regexp::MULTILINE)

    RegexLineBreak =
        Regexp.new("(\\\\*)(\\~(?:\n|\\z))")

    #Other syntax
    RegexPlugin = 
        Regexp.new("(\\\\*)((\\[{2,}[\u0020\u00A0]*\\[*)|(\\]{2,}[\u0020\u00A0]*\\]*))")
    RegexCommentOut = 
        Regexp.new("(\\\\*)(\#{2,})", Regexp::MULTILINE)
    RegexsplitOption = 
        Regexp.new("(\\\\*)(::)", Regexp::MULTILINE)

    #Other
    RegexEscape = 
        Regexp.new("\\\\+", Regexp::MULTILINE)
    RegexProtocol = 
        Regexp.new(":{1,1}(/{2,})", Regexp::MULTILINE)
    RegexWhiteSpace = 
        Regexp.new("\s")
    RegexWhiteSpaceLine = 
        Regexp.new("^[\t\v\f\u0020\u00A0]+$")
    RegexLineBreakCode = 
        Regexp.new("\r\n|\r|\n")
    RegexBlankLine = 
        Regexp.new("^\n")
    RegexPreElement = 
        Regexp.new("(<pre\s*.*?>)|</pre>", Regexp::IGNORECASE)
    RegexLinkElement = 
        Regexp.new("(?:<a.*?>.*?</a>)|(?:<img.*?>)|(?:<video.*?>.*?</video>)" + 
                   "|(?:<audio.*?>.*?</audio>)|<object.*?>.*?</object>",
                    Regexp::IGNORECASE)
    RegexStringTypeAttribute =
        Regexp.new("([^\s]+?)\s*=\s*\"(.+?)\"")
    RegexFileExtension =
        Regexp.new(".+\\.(.+?)\\z")

    BlockGroupTypeUndefined = -1
    BlockGroupTypeDiv = 0
    BlockGroupTypeDetails = 8
    BlockGroupTypeFigure = 9
    BlockGroupTypePre = 10
    BlockGroupTypeCode = 11
    BlockGroupTypeKbd = 12
    BlockGroupTypeSamp = 13

    ReservedBlockGroupTypes =
    [
        "div", "header", "footer", "nav",
        "article", "section", "aside", "address",
        "details", "figure",
        "pre", "code", "kbd", "samp"
    ]

    InlineMarkupTypeDefAbbr = 5
    InlineMarkupTypeVarCode = 6
    InlineMarkupTypeKbdSamp = 7
    InlineMarkupTypeSupRuby = 8
    InlineMarkupTypeLinkOpen= 11
    InlineMarkupTypeLinkClose = 12
    InlineMarkupTypeInlineGroupOpen = 13
    InlineMarkupTypeInlineGroupClose = 14

    InlineMarkupSets =
    [
        ["*", "b", "strong"],
        ["/", "i", "em"],
        ["_", "u", "ins"],
        ["%", "s", "del"],
        ["@", "cite", "small"],
        ["?", "dfn", "abbr"],
        ["$", "kbd", "samp"],
        ["`", "var", "code"],
        ["'", "sup", "ruby"],
        [",", "sub"],
        ["\"", "q"],
        ["(",  "a"],
        [")",  "a"],
        ["<",  "span"],
        [">",  "span"],
    ]

    MediaTypeImage = 0
    MediaTypeAudio = 1
    MediaTypeVideo = 2
    MediaTypeUnknown = 3

    MediaExtensions =
    [
        /bmp|bitmap|gif|jpg|jpeg|png/i,
        /aac|aiff|flac|mp3|ogg|wav|wave/i,
        /asf|avi|flv|mov|movie|mpg|mpeg|mp4|ogv|webm/i
    ]

    ReservedObjectAttributes =
    [
        "width", "height", "type", "typemustmatch", "name", "usemap", "form"
    ]

    ListTypeUl = true
    ListTypeOl = false

    PluginDirectory = "./plugins"
    DefaultEscapeCode = "escpcode"





    public
    def convert(text, pluginDirectory = KARAS::PluginDirectory)
        escapeCode = KARAS::generateSafeEscapeCode(text, KARAS::DefaultEscapeCode)
        lineBreakCode = KARAS::getDefaultLineBreakCode(text)
        text = text.gsub("\r\n", "\n")
        text = text.gsub("\r", "\n")

        text = KARAS::replaceTextInPluginSyntax(text, ">", escapeCode + ">")
        text = KARAS::replaceTextInPluginSyntax(text, "{", escapeCode + "{")
        text = KARAS::replaceTextInPreElement(text, "\n", escapeCode + "\n" + escapeCode)
        hasUnConvertedBlockquote = true
        while hasUnConvertedBlockquote
            text = KARAS::convertBlockGroup(text, escapeCode)
            text, hasUnConvertedBlockquote = 
                KARAS::convertBlockquote(text, hasUnConvertedBlockquote, escapeCode)
        end

        pluginManager = KARAS::PluginManager.new(pluginDirectory)
        text = text.gsub(escapeCode, "")
        text = KARAS::replaceTextInPreElement(text, "[",  escapeCode + "[")
        text = KARAS::convertPlugin(text, pluginManager)

        text = KARAS::replaceTextInPreElement(text, "\n", escapeCode + "\n" + escapeCode)
        hasUnConvertedBlockquote = true
        while hasUnConvertedBlockquote
            text = KARAS::convertBlockGroup(text, escapeCode)
            text, hasUnConvertedBlockquote = 
                KARAS::convertBlockquote(text, hasUnConvertedBlockquote, escapeCode)
        end

        text = KARAS::replaceTextInPreElement(text, "#",  escapeCode + "#")
        text = KARAS::convertCommentOut(text)
        text = KARAS::convertWhiteSpaceLine(text)
        text = KARAS::convertProtocol(text)
        text = KARAS::convertTable(text)
        text = KARAS::convertList(text)
        text = KARAS::convertDefList(text)
        text = KARAS::convertHeading(text)
        text = KARAS::convertBlockLink(text)
        text = KARAS::convertParagraph(text)
        text = KARAS::reduceBlankLine(text)

        text = text.gsub(escapeCode, "")
        text = KARAS::replaceTextInPreElement(text, "\\",  escapeCode)
        text = KARAS::reduceEscape(text)
        text = KARAS::replaceTextInPreElement(text, escapeCode, "\\")
        text = text.gsub("\n", lineBreakCode)

        return text
    end

    public
    def getDefaultLineBreakCode(text)
        #match group index.
        mgiAllText = 0

        match = KARAS::RegexLineBreakCode.match(text)

        if match != nil
            return match[mgiAllText]
        else
            return "\n"
        end
    end

    public
    def generateSafeEscapeCode(text, escapeCode)
        while true
            if text.include?(escapeCode) == false
                break
            end

            escapeCode = [*:a..:z,*0..9].sample(8).join
        end

        return escapeCode
    end

    class PluginMatch
        attr_accessor :index
        attr_accessor :marks

        def initialize()
            @index = -1
            @marks = ""
        end
    end

    public
    def replaceTextInPluginSyntax(text, oldText, newText)
        #match group index.
        mgiAllText = 0
        mgiEscapes = 1
        mgiMarks = 2
        mgiOpenMarks = 3
        #mgiCloseMarks = 4

        matchStack = Array.new()
        match = nil
        nextMatchIndex = 0

        while true
            match = KARAS::RegexPlugin.match(text, nextMatchIndex)

            if match == nil
                break                    
            end

            if match[mgiEscapes].length % 2 == 1
                nextMatchIndex = match.begin(mgiMarks) + 1
                next
            end

            if match[mgiOpenMarks] != nil
                pluginMatch = KARAS::PluginMatch.new()
                pluginMatch.index = match.begin(mgiMarks)
                matchStack.unshift(pluginMatch)
                nextMatchIndex = match.begin(mgiAllText) + match[mgiAllText].length
                next
            end

            if matchStack.length == 0
                nextMatchIndex = match.begin(mgiAllText) + match[mgiAllText].length
                next
            end

            preMatch = matchStack.shift()
            markedupText = text[preMatch.index, match.begin(mgiMarks) - preMatch.index]
            markedupText = markedupText.gsub(oldText, newText)

            text = KARAS::removeAndInsertText(text,
                                              preMatch.index,
                                              match.begin(mgiMarks) - preMatch.index,
                                              markedupText)
            nextMatchIndex = preMatch.index + markedupText.length
        end

        return text
    end

    public
    def replaceTextInPreElement(text, oldText, newText)
        # match group index.
        mgiAllText = 0
        mgiOpenPreElement = 1

        matchStack = Array.new()
        match = nil
        nextMatchIndex = 0

        while true
            match = KARAS::RegexPreElement.match(text, nextMatchIndex)

            if match == nil
                break
            end

            if match[mgiOpenPreElement] != nil
                index = match.begin(mgiOpenPreElement) + match[mgiOpenPreElement].length
                matchStack.unshift(index)
                nextMatchIndex = index
                next
            end

            if matchStack.length == 0
                nextMatchIndex = match.begin(mgiAllText) + match[mgiAllText].length
                next
            end

            preTextStart = matchStack.shift()
            preTextEnd = match.begin(mgiAllText)
            preText = text[preTextStart, preTextEnd - preTextStart]
            preText = preText.gsub(oldText, newText)
            text = KARAS::removeAndInsertText(text,
                                              preTextStart,
                                              preTextEnd - preTextStart,
                                              preText)
            nextMatchIndex = preTextStart + newText.length + match[mgiAllText].length
        end

        return text
    end





    public
    def encloseWithLineBreak(text)
        return "\n" + text + "\n"
    end

    public
    def escapeHtmlSpecialCharacters(text)
        text = text.gsub("&", "&amp;")
        text = text.gsub("\"", "&#34;")
        text = text.gsub("'", "&#39;")
        text = text.gsub("<", "&lt;")
        text = text.gsub(">", "&gt;")

        return text
    end

    public
    def removeAndInsertText(text, index, removeLength, newText)
        text.slice!(index, removeLength)
        return text.insert(index, newText)
    end

    public
    def removeWhiteSpace(text)
        return text.gsub(KARAS::RegexWhiteSpace, "")
    end

    public
    def splitOption(text)
        #match group index.
        #mgiAllText = 0
        mgiEscapes = 1
        mgiMarks = 2

        match = nil
        nextMatchIndex = 0

        while true
            match = KARAS::RegexsplitOption.match(text, nextMatchIndex)

            if match == nil
                return [text.strip()]
            end

            if match[mgiEscapes].length % 2 == 1
                nextMatchIndex = match.begin(mgiMarks) + 1
                next
            end

            return [
                        text[0, match.begin(mgiMarks)].strip(),
                        text[match.end(mgiMarks)..text.length].strip()
                   ]
        end
    end

    public
    def splitOptions(text)
        textList = Array.new()
        restText = text.strip()

        while true
            splitTexts = KARAS::splitOption(restText)

            if splitTexts.length == 1
                textList.push(restText)
                break
            end

            textList.push(splitTexts[0])
            restText = splitTexts[1]
        end

        return textList
    end





    class PluginManager
        public
        def initialize(pluginDirectory)
            # Key = Lowercase plugin name, Value = Plugin
            @loadedPluginHash = Hash.new()
            # Key = Original plugin name, Value = File path
            @pluginFilePathHash = Hash.new()

            loadPluginFilePaths(PluginManager.getSafeDirectoryPath(pluginDirectory))
        end

        public
        def self.getSafeDirectoryPath(directory)
             lastchar = directory[-1]

            if(lastchar == "/")
                return directory
            else
                return directory + "/"
            end
        end

        private
        def loadPluginFilePaths(pluginDirectory)
            PluginManager.getPluginFilePaths(pluginDirectory).each do |filePath|
                pluginName = File.basename(filePath, ".*")
                @pluginFilePathHash[pluginName] = filePath
            end
        end

        public
        def self.getPluginFilePaths(pluginDirectory)
            if File.exist?(pluginDirectory) == true
                return Dir.glob(pluginDirectory + "*\.rb")
            end

            return Array.new(0)
        end

        public
        def getPlugin(pluginName)
            pluginName = pluginName.downcase()

            if @loadedPluginHash.has_key?(pluginName)
                return @loadedPluginHash[pluginName]
            end

            return loadAndCachePlugin(pluginName)
        end

        public
        def loadAndCachePlugin(pluginName)
            begin
                @pluginFilePathHash.each_key() do |key|
                    if key.downcase() == pluginName
                        require @pluginFilePathHash[key]
                        plugin = Module.const_get(key)
                        @loadedPluginHash.store(pluginName, plugin)
                        return plugin
                    end
                end
            rescue
                @loadedPluginHash.store(pluginName.downcase(), nil)
                return nil
            end

            @loadedPluginHash.store(pluginName.downcase(), nil)
            return nil
        end
    end

    public
    def convertPlugin(text, pluginManager)
        #match group index.
        mgiAllText = 0
        mgiEscapes = 1
        mgiMarks = 2
        mgiOpenMarks = 3
        mgiCloseMarks = 4

        matchStack = Array.new()
        match = nil
        nextMatchIndex = 0

        while true
            match = KARAS::RegexPlugin.match(text, nextMatchIndex)

            if match == nil
                break
            end

            if match[mgiEscapes].length % 2 == 1
                nextMatchIndex = match.begin(mgiMarks) + 1
                next
            end

            if match[mgiOpenMarks] != nil
                pluginMatch = KARAS::PluginMatch.new()
                pluginMatch.index = match.begin(mgiMarks)
                pluginMatch.marks = match[mgiMarks]
                matchStack.unshift(pluginMatch)
                nextMatchIndex = match.begin(mgiAllText) + match[mgiAllText].length
                next
            end

            if matchStack.length == 0
                nextMatchIndex = match.begin(mgiAllText) + match[mgiAllText].length
                next
            end

            preMatch = matchStack.shift()
            markedupTextIndex = preMatch.index + preMatch.marks.length
            markedupText = text[markedupTextIndex, match.begin(mgiAllText) - markedupTextIndex]
            openMarks = KARAS::removeWhiteSpace(preMatch.marks)
            closeMarks = KARAS::removeWhiteSpace(match[mgiCloseMarks])
            newText = constructPluginText(text,
                                          markedupText,
                                          openMarks,
                                          closeMarks,
                                          pluginManager)
            markDiff = openMarks.length - closeMarks.length

            if markDiff > 0
                openMarks.slice!(markDiff..openMarks.length)
                closeMarks = ""

                if markDiff > 1
                  openMarks.slice!(markDiff..openMarks.length)
                    preMatch.marks = openMarks
                    matchStack.unshift(preMatch)
                end
            else
                openMarks = ""
                closeMarks.slice!(-markDiff..closeMarks.length)
            end

            newText = openMarks + newText + closeMarks

            #It is important to trim close marks to exclude whitespace out of syntax.
            text = KARAS::removeAndInsertText(text,
                                              preMatch.index,
                                              match.begin(mgiAllText) + 
                                              match[mgiAllText].strip().length -
                                              preMatch.index,
                                              newText)
            nextMatchIndex = preMatch.index + newText.length - closeMarks.length
        end

        return text
    end

    private
    def constructPluginText(text, markedupText, openMarks, closeMarks, pluginManager)
        markedupTexts = KARAS::splitOptions(markedupText)
        pluginName = markedupTexts[0]
        options = Array.new()

        if openMarks.length > 2 && closeMarks.length > 2
            if markedupTexts.length > 1
                options = markedupTexts[1..(markedupTexts.length - 1)]
            end

            return constructActionTypePluginText(pluginManager,
                                                 pluginName,
                                                 text,
                                                 options)
        else
            markedupText = markedupTexts[markedupTexts.length - 1]

            if markedupTexts.length > 2
                options = markedupTexts[1..(markedupTexts.length - 2)]
            end

            return constructConvertTypePluginText(pluginManager,
                                                  pluginName,
                                                  markedupText,
                                                  options)
        end
    end

    private
    def constructConvertTypePluginText(pluginManager, pluginName, markedupText, options)
        plugin = pluginManager.getPlugin(pluginName)

        if plugin == nil
            return " Plugin \"" + pluginName + "\" has wrong. "
        end

        begin
            return plugin.convert(markedupText, options)
        rescue
            return " Plugin \"" + pluginName + "\" has wrong. "
        end
    end

    private
    def constructActionTypePluginText(pluginManager, pluginName, text, options)
        plugin = pluginManager.getPlugin(pluginName)

        if plugin == nil
            return " Plugin \"" + pluginName + "\" has wrong. "
        end

        begin
            return  plugin.action(text, options)
        rescue
            return " Plugin \"" + pluginName + "\" has wrong. "
        end
    end





    class BlockGroupMatch
        attr_accessor :type
        attr_accessor :index
        attr_accessor :length
        attr_accessor :option

        def initialize()
            @type = -1
            @index = -1
            @length = -1
            @option = ""
        end
    end

    public
    def convertBlockGroup(text, escapeCode)
        #match group index.
        mgiAllText = 0
        mgiOpenMarks = 1
        mgiOption = 2

        match = nil
        nextMatchIndex = 0

        matchStack = Array.new()
        unhandledGroupClose = nil
        groupsInPreCodeKbdSamp = 0

        while true
            match = KARAS::RegexBlockGroup.match(text, nextMatchIndex)

            if match == nil
                if groupsInPreCodeKbdSamp > 0 && unhandledGroupClose != nil
                    match = unhandledGroupClose
                    groupsInPreCodeKbdSamp = 0
                else
                    break
                end
            end

            if match[mgiOpenMarks] != nil
                blockGroupMatch = constructBlockGroupMatch(match.begin(mgiAllText),
                                                           match[mgiAllText].length,
                                                           match[mgiOption])

                if blockGroupMatch.type >= KARAS::BlockGroupTypePre
                    groupsInPreCodeKbdSamp += 1

                    if groupsInPreCodeKbdSamp == 1
                        matchStack.unshift(blockGroupMatch)
                    end
                else
                    #if pre or code group is open.
                    if groupsInPreCodeKbdSamp > 0
                        groupsInPreCodeKbdSamp += 1
                    else
                        matchStack.unshift(blockGroupMatch)
                    end
                end

                nextMatchIndex = match.begin(mgiAllText) + match[mgiAllText].length
                next
            end

            if matchStack.length == 0
                nextMatchIndex = match.begin(mgiAllText) + match[mgiAllText].length
                next
            end

            if groupsInPreCodeKbdSamp > 1
                groupsInPreCodeKbdSamp -= 1
                unhandledGroupClose = match
                nextMatchIndex = match.begin(mgiAllText) + match[mgiAllText].length
                next
            end

            preMatch = matchStack.shift()
            newOpenText, newCloseText = constructBlockGroupText(preMatch, newOpenText, newCloseText)

            #Note, it is important to exclude linebreak code.
            markedutTextIndex = preMatch.index + preMatch.length + 1
            markedupText = text[markedutTextIndex, match.begin(mgiAllText) - markedutTextIndex - 1]

            case preMatch.type
                when KARAS::BlockGroupTypeDetails
                    markedupText = convertFigcaptionSummary(markedupText, "summary")
                when KARAS::BlockGroupTypeFigure
                    markedupText = convertFigcaptionSummary(markedupText, "figcaption")
                when KARAS::BlockGroupTypePre, KARAS::BlockGroupTypeCode, 
                     KARAS::BlockGroupTypeKbd, KARAS::BlockGroupTypeSamp
                    markedupText = KARAS::escapeHtmlSpecialCharacters(markedupText)
                    markedupText = markedupText.gsub("\n", escapeCode + "\n" + escapeCode)
                    groupsInPreCodeKbdSamp = 0
            end

            newText = newOpenText + markedupText + newCloseText
            text = KARAS::removeAndInsertText(text,
                                              preMatch.index,
                                              match.begin(mgiAllText) + 
                                              match[mgiAllText].length - 
                                              preMatch.index,
                                              newText)
            nextMatchIndex = preMatch.index + newText.length
        end

        return text
    end

    private
    def constructBlockGroupMatch(index, textLength, optionText)
        blockGroupMatch = BlockGroupMatch.new()
        blockGroupMatch.index = index
        blockGroupMatch.length = textLength

        options = KARAS::splitOptions(optionText)

        if options.length > 0
            groupType = options[0]
            blockGroupMatch.type = getGroupType(groupType)

            if blockGroupMatch.type == KARAS::BlockGroupTypeUndefined
                blockGroupMatch.type = KARAS::BlockGroupTypeDiv
                blockGroupMatch.option = groupType
            end
        end

        if options.length > 1
            blockGroupMatch.option = options[1]
        end

        return blockGroupMatch
    end

    private
    def getGroupType(groupTypeText)
        0.upto(KARAS::ReservedBlockGroupTypes.length - 1) do |i|
            if groupTypeText.casecmp(KARAS::ReservedBlockGroupTypes[i]) == 0
                return i
            end
        end

        return KARAS::BlockGroupTypeUndefined
    end

    private
    def constructBlockGroupText(groupOpen, newOpenText, newCloseText)
        newCloseText = "</" + KARAS::ReservedBlockGroupTypes[groupOpen.type] + ">"
        optionText = ""

        if groupOpen.option.length != 0
            optionText = " class=\"" + groupOpen.option + "\""
        end

        newOpenText = "<" + KARAS::ReservedBlockGroupTypes[groupOpen.type] + optionText + ">"

        if groupOpen.type >= KARAS::BlockGroupTypePre
            if groupOpen.type >= KARAS::BlockGroupTypeCode
                newOpenText = "<pre" + optionText + ">" + newOpenText
                newCloseText += "</pre>"
            end

            newOpenText = "\n" + newOpenText
            newCloseText = newCloseText + "\n"
        else
            newOpenText = KARAS::encloseWithLineBreak(newOpenText) + "\n"
            newCloseText = "\n" + KARAS::encloseWithLineBreak(newCloseText)
        end

        return newOpenText, newCloseText
    end

    private
    def convertFigcaptionSummary(text, element)
        #match group index.
        mgiAllText = 0
        mgiMarks = 1
        mgiMarkedupText = 2
        mgiBreaks = 3

        maxLevelOfHeading = 6

        match = nil
        nextMatchIndex = 0

        while true
            match = KARAS::RegexFigcaptionSummary.match(text, nextMatchIndex)

            if match == nil
                break
            end

            newText = ""
            level = match[mgiMarks].length

            if level >= maxLevelOfHeading + 1
                newText = KARAS::encloseWithLineBreak("<hr>")
            else
                #Note, it is important to convert inline markups first,
                #to convert inline markup's options first.
                markedupText = KARAS::convertInlineMarkup(match[mgiMarkedupText])
                markedupTexts = KARAS::splitOptions(markedupText)
                id = ""

                if markedupTexts.length > 1
                    id = " id=\"" + markedupTexts[1] + "\""
                end

                newText = KARAS::encloseWithLineBreak("<" + element + id + ">" +
                                                      markedupTexts[0] + "</" +
                                                      element + ">")
            end

            nextMatchIndex = match.begin(mgiAllText) + newText.length
            text = KARAS::removeAndInsertText(text,
                                              match.begin(mgiAllText),
                                              match[mgiAllText].length - match[mgiBreaks].length,
                                              KARAS::encloseWithLineBreak(newText))
        end

        return text
    end

    class SequentialBlockquote
        attr_accessor :level        
        attr_accessor :text

        def initialize()
            @leve = -1
            @text = ""
        end
    end

    public
    def convertBlockquote(text, hasUnConvertedBlockquote, escapeCode)
        #match group index.
        mgiAllText = 0

        match = nil
        nextMatchIndex = 0

        while true
            match = KARAS::RegexBlockquote.match(text, nextMatchIndex)

            if match == nil
                if nextMatchIndex == 0
                    hasUnConvertedBlockquote = false
                else
                    hasUnConvertedBlockquote = true
                end

                break
            end

            sequentialBlockquotes = Array.new()
            indexOfBlockquoteStart = match.begin(mgiAllText)
            indexOfBlockquoteEnd = constructSequentialBlockquotes(text,
                                                                  indexOfBlockquoteStart,
                                                                  sequentialBlockquotes)

            newText = constructBlockquoteText(sequentialBlockquotes)
            newText = KARAS::replaceTextInPreElement(newText, "\n", escapeCode + "\n" + escapeCode)
            newText = KARAS::encloseWithLineBreak(newText)
            nextMatchIndex = indexOfBlockquoteStart + newText.length
            text = KARAS::removeAndInsertText(text,
                                              indexOfBlockquoteStart,
                                              indexOfBlockquoteEnd - indexOfBlockquoteStart,
                                              KARAS::encloseWithLineBreak(newText))
        end

        return text, hasUnConvertedBlockquote
    end

    private
    def constructSequentialBlockquotes(text, indexOfBlockquoteStart, blockquotes)
        #match group index.
        mgiAllText = 0
        mgiMarks = 1
        mgiMarkedupText = 2
        mgiNextMarks = 3
        mgiBreaks = 4

        match = nil
        nextMatchIndex = indexOfBlockquoteStart

        while true
            match = KARAS::RegexBlockquote.match(text, nextMatchIndex)

            if match == nil
                break
            end

            level = match[mgiMarks].length
            markedupText = match[mgiMarkedupText]

            if blockquotes.length == 0
                sequentialBlockquote = KARAS::SequentialBlockquote.new()
                sequentialBlockquote.level = level
                sequentialBlockquote.text = markedupText.strip()
                blockquotes.push(sequentialBlockquote)
            else
                previousBlockquote = blockquotes[blockquotes.length - 1]
                previousLevel = previousBlockquote.level

                if level != previousLevel
                    sequentialBlockquote = KARAS::SequentialBlockquote.new()
                    sequentialBlockquote.level = level
                    sequentialBlockquote.text = markedupText.strip()
                    blockquotes.push(sequentialBlockquote)
                else
                    if previousBlockquote.text != nil
                        previousBlockquote.text += "\n"
                    end

                    previousBlockquote.text += markedupText.strip()
                end
            end

            if match[mgiNextMarks] == nil
                return match.begin(mgiAllText) + 
                       match[mgiAllText].length - 
                       (match[mgiBreaks] == nil ? 0 : match[mgiBreaks].length)
            end

            nextMatchIndex = match.begin(mgiNextMarks)
        end

        return -1
    end

    private
    def constructBlockquoteText(sequentialBlockquotes)
        blockquoteText = ""

        (sequentialBlockquotes[0].level).times do
            blockquoteText += "<blockquote>\n\n"
        end

        blockquoteText += sequentialBlockquotes[0].text

        1.upto(sequentialBlockquotes.length - 1) do |i|
            levelDiff = sequentialBlockquotes[i].level - sequentialBlockquotes[i - 1].level

            if levelDiff > 0
                levelDiff.times do
                    blockquoteText += "\n\n<blockquote>"
                end
            else
                levelDiff *= -1
                levelDiff.times do
                    blockquoteText += "\n\n</blockquote>"
                end
            end

            blockquoteText += "\n\n" + sequentialBlockquotes[i].text
        end

        sequentialBlockquotes[sequentialBlockquotes.length - 1].level.times do
            blockquoteText += "\n\n</blockquote>"
        end

        return blockquoteText
    end





    public
    def convertCommentOut(text)
        #match group index.
        mgiAllText = 0
        mgiEscapes = 1
        mgiMarks = 2

        match = nil
        nextMatchIndex = 0
        indexOfOpenMarks = 0
        markIsOpen = false

        while true
            match = KARAS::RegexCommentOut.match(text, nextMatchIndex)

            if match == nil
                break
            end

            if match[mgiEscapes].length % 2 == 1
                nextMatchIndex = match.begin(mgiMarks) + 1
                next
            end

            if markIsOpen == false
                markIsOpen = true
                indexOfOpenMarks = match.begin(mgiMarks)
                nextMatchIndex = indexOfOpenMarks + match[mgiMarks].length
                next
            end

            text.slice!(indexOfOpenMarks,
                        match.begin(mgiAllText) + match[mgiAllText].length - indexOfOpenMarks)
            markIsOpen = false
            nextMatchIndex = indexOfOpenMarks
        end

        return text
    end

    public
    def convertWhiteSpaceLine(text)
        #match group index.
        mgiAllText = 0

        match = nil
        nextMatchIndex = 0

        while true
            match = KARAS::RegexWhiteSpaceLine.match(text)

            if match == nil
                break
            end

            newText = "\n"
            text = KARAS::removeAndInsertText(text,
                                              match.begin(mgiAllText),
                                              match[mgiAllText].length,
                                              newText)
            nextMatchIndex = match.begin(mgiAllText) + newText.length
        end

        return text
    end

    public
    def convertProtocol(text)
        #match group index.
        #mgiAllText = 0
        mgiMarks = 1

        match = nil
        nextMatchIndex = 0

        while true
            match = KARAS::RegexProtocol.match(text, nextMatchIndex)

            if match == nil
                break
            end

            newText = ""

            match[mgiMarks].length.times do |i|
                newText += "\\/"
            end

            nextMatchIndex = match.begin(mgiMarks) + newText.length
            text = KARAS::removeAndInsertText(text,
                                              match.begin(mgiMarks),
                                              match[mgiMarks].length,
                                              newText)
        end

        return text
    end

    class TableCell
        attr_accessor :isCollSpanBlank
        attr_accessor :isRowSpanBlank
        attr_accessor :type
        attr_accessor :textAlign
        attr_accessor :text

        def initialize()
            @isCollSpanBlank = false
            @isRowSpanBlank = false
            @type = ""
            @textAlign = ""
            @text = ""
        end
    end

    public
    def convertTable(text)
        #match group index.
        mgiAllText = 0
        mgiTableText = 1
        mgiBreaks = 2

        match = nil
        nextMatchIndex = 0

        while true
            match = KARAS::RegexTableBlock.match(text, nextMatchIndex)

            if match == nil
                break
            end

            cells = constructTableCells(match[mgiTableText])
            newText = constructTableText(cells)
            newText = KARAS::encloseWithLineBreak(newText)
            nextMatchIndex = match.begin(mgiAllText) + newText.length
            text = KARAS::removeAndInsertText(text,
                                              match.begin(mgiAllText),
                                              match[mgiAllText].length - match[mgiBreaks].length,
                                              KARAS::encloseWithLineBreak(newText))
        end

        return text
    end

    private
    def constructTableCells(tableBlock)
        #match group index.
        mgiAllText = 0
        mgiEscapes = 1
        mgiCellType = 2
        mgiTextAlign = 3

        #like '||' or any other...
        tableCellMarkLength = 2

        tableLines = tableBlock.split("\n")
        cells = [tableLines.length]

        0.upto(tableLines.length - 1) do |i|
            tableLine = tableLines[i]
            cells[i] = Array.new()
            match = nil
            markedupText = ""
            nextMatchIndex = 0

            while true
                match = KARAS::RegexTableCell.match(tableLine, nextMatchIndex)

                if match == nil
                    markedupText = tableLine[nextMatchIndex..tableLine.length]

                    if cells[i].length > 0
                        setTableCellTextAndBlank(cells[i][cells[i].length - 1], markedupText)
                    end

                    break
                end

                if match[mgiEscapes].length % 2 == 1
                    nextMatchIndex = match.begin(mgiCellType) + 1
                    next
                end

                cell = KARAS::TableCell.new()
                setTableCellTypeAndAlign(cell, match[mgiCellType], match[mgiTextAlign])
                markedupText = 
                    tableLine[nextMatchIndex, match.begin(mgiAllText) - nextMatchIndex]

                if cells[i].length > 0
                    setTableCellTextAndBlank(cells[i][cells[i].length - 1], markedupText)
                end

                cells[i].push(cell)
                nextMatchIndex = match.begin(mgiAllText) + tableCellMarkLength
            end
        end

        return cells
    end

    private
    def setTableCellTypeAndAlign(cell, cellTypeMark, textAlignMark)
        if cellTypeMark == "|"
            cell.type = "td"
        else
            cell.type = "th"
        end

        case textAlignMark
            when ">"
                cell.textAlign = " style=\"text-align:right\""
            when "<"
                cell.textAlign = " style=\"text-align:left\""
            when "="
                cell.textAlign = " style=\"text-align:center\""
            else
                cell.textAlign = ""
        end
    end

    private
    def setTableCellTextAndBlank(cell, markedupText)
        markedupText = markedupText.strip()

        case markedupText
            when "::"
                cell.isCollSpanBlank = true
            when ":::"
                cell.isRowSpanBlank = true
            else
                cell.text = KARAS::convertInlineMarkup(markedupText)
        end
    end

    private
    def constructTableText(cells)
        tableText = "<table>\n"

        0.upto(cells.length - 1) do |row|
            tableText += "<tr>"

            0.upto(cells[row].length - 1) do |column|
                cell = cells[row][column]

                if cell.isCollSpanBlank || cell.isRowSpanBlank
                    next
                end

                columnBlank = countBlankColumn(cells, column, row)
                rowBlank = countBlankRow(cells, column, row)
                colspanText = ""
                rowspanText = ""

                if columnBlank > 1
                    colspanText = " colspan = \"" + columnBlank.to_s() + "\""
                end

                if rowBlank > 1
                    rowspanText = " rowspan = \"" + rowBlank.to_s() + "\""
                end

                tableText += "<" + cell.type + colspanText + rowspanText +
                             cell.textAlign + ">" + cell.text + "</" + cell.type + ">"
            end

            tableText += "</tr>\n"
        end

        tableText += "</table>"
        return tableText
    end

    private
    def countBlankColumn(cells, column, row)
        blank = 1
        rightColumn = column + 1

        while rightColumn < cells[row].length
            rightCell = cells[row][rightColumn]

            if rightCell.isCollSpanBlank
                blank += 1
                rightColumn += 1
            else
                break
            end
        end

        return blank
    end

    private
    def countBlankRow(cells, column, row)
        blank = 1
        underRow = row + 1

        while underRow < cells.length
            #Note, sometimes there is no column in next row.
            if column >= cells[underRow].length
                break
            end

            underCell = cells[underRow][column]

            if underCell.isRowSpanBlank
                blank += 1
                underRow += 1
            else
                break
            end
        end

        return blank
    end

    class SequentialList
        attr_accessor :type
        attr_accessor :level
        attr_accessor :items

        def initialize()
            @type = false
            @leve = -1
            @items = Array.new()
        end
    end

    public
    def convertList(text)
        #match group index.
        mgiAllText = 0

        match = nil
        nextMatchIndex = 0

        while true
            match = KARAS::RegexList.match(text, nextMatchIndex)

            if match == nil
                break
            end

            sequentialLists = Array.new()
            listStartIndex = match.begin(mgiAllText)
            listEndIndex = constructSequentialLists(text, listStartIndex, sequentialLists)

            newText = constructListText(sequentialLists)
            newText = KARAS::encloseWithLineBreak(newText)
            nextMatchIndex = listStartIndex + newText.length
            text = KARAS::removeAndInsertText(text,
                                              listStartIndex,
                                              listEndIndex - listStartIndex,
                                              KARAS::encloseWithLineBreak(newText));
        end

        return text
    end

    private
    def constructSequentialLists(text, indexOfListStart, sequentialLists)
        #match group index.
        mgiAllText = 0
        mgiMarks = 1
        mgiMarkedupText = 2
        mgiNextMarks = 3
        mgiBreaks = 4

        match = nil
        nextMatchIndex = indexOfListStart
        levelDiff = 0
        previousLevel = 0

        while true
            match = KARAS::RegexList.match(text, nextMatchIndex)

            if match == nil
                break
            end

            #Update
            levelDiff = match[mgiMarks].length - previousLevel
            previousLevel = match[mgiMarks].length

            #If start of the items. || If Level up or down.
            if levelDiff != 0
                sequentialList = KARAS::SequentialList.new()

                if match[mgiMarks][match[mgiMarks].length - 1] == '-'
                    sequentialList.type = KARAS::ListTypeUl
                #If  == '+'
                else
                    sequentialList.type = KARAS::ListTypeOl
                end

                sequentialList.level = match[mgiMarks].length
                sequentialList.items.push(match[mgiMarkedupText])
                sequentialLists.push(sequentialList)
            
            #If same Level.
            else 
                previousSequentialList = sequentialLists[sequentialLists.length - 1]
                listType = KARAS::ListTypeUl

                if match[mgiMarks][match[mgiMarks].length - 1] == '-'
                    listType = KARAS::ListTypeUl
                #If == '+'
                else
                    listType = KARAS::ListTypeOl
                end

                if listType != previousSequentialList.type
                    sequentialList = KARAS::SequentialList.new()
                    sequentialList.type = listType
                    sequentialList.level = match[mgiMarks].length
                    sequentialList.items.push(match[mgiMarkedupText])
                    sequentialLists.push(sequentialList)
                #If same items type.
                else
                    previousSequentialList.items.push(match[mgiMarkedupText])
                end
            end

            if match[mgiNextMarks] == nil
                return match.begin(mgiAllText) + 
                       match[mgiAllText].length - 
                       (match[mgiBreaks] == nil ? 0 : match[mgiBreaks].length)
            end

            nextMatchIndex = match.begin(mgiNextMarks)
        end

        return -1
    end

    private
    def constructListText(sequentialLists)
        #Key = Level, Value = isUL(true:ul, false:ol)
        listTypeHash = constructListTypeHash(sequentialLists)
        listText = ""

        listText += constructFirstSequentialListText(sequentialLists[0], listTypeHash)

        #Write later lists.
        previousLevel = sequentialLists[0].level

        1.upto(sequentialLists.length - 1) do |i|
            sequentialList = sequentialLists[i]

            #If level up.
            if previousLevel < sequentialList.level
                listText += constructUpLevelSequentialListText(previousLevel,
                                                               sequentialList,
                                                               listTypeHash)
            #If level down.
            elsif previousLevel > sequentialList.level
                    listText += constructDownLevelSequentialListText(previousLevel,
                                                                     sequentialList,
                                                                     listTypeHash)
            #If same level.(It means the list type is changed.)
            else
                listText += constructSameLevelSequentialListText(previousLevel,
                                                                 sequentialList,
                                                                 listTypeHash)
            end

            previousLevel = sequentialList.level
        end

        listText += constructListCloseText(previousLevel, listTypeHash)

        return KARAS::encloseWithLineBreak(listText)
    end

    private
    def constructListTypeHash(sequentialLists)
        listTypeHash = Hash.new()
        maxLevel = 1

        sequentialLists.each do |list|
            if maxLevel < list.level
                maxLevel = list.level
            end

            if listTypeHash.has_key?(list.level) == false
                listTypeHash.store(list.level, list.type)
            end
        end

        #If there is undefined level,
        #set the list type of the next higher defined level to it.
        #Note, the maximum level always has level type.
        1.upto(maxLevel - 1) do |level|
            if listTypeHash.has_key?(level) == false
                typeUndefinedLevels = Array.new()
                typeUndefinedLevels.push(level)

                (level + 1).upto(maxLevel) do |nextLevel|
                    if listTypeHash.has_key?(nextLevel)
                        typeUndefinedLevels.each do |typeUndefinedLevel|
                            listTypeHash.store(typeUndefinedLevel, listTypeHash[nextLevel])
                        end
                        #Skip initialized level.
                        level = nextLevel + 1
                        break
                    end

                    typeUndefinedLevels.push(nextLevel)
                end
            end
        end

        return listTypeHash
    end

    private
    def constructFirstSequentialListText(sequentialList, listTypeHash)
        listText = ""

        1.upto(sequentialList.level - 1) do |level|
            if listTypeHash[level] == KARAS::ListTypeUl
                listText += "<ul>\n<li>\n"
            else
                listText += "<ol>\n<li>\n"
            end
        end

        if sequentialList.type == KARAS::ListTypeUl
            listText += "<ul>\n<li"
        else
            listText += "<ol>\n<li"
        end

        0.upto(sequentialList.items.length - 2) do |i|
            listText += constructListItemText(sequentialList.items[i]) + "</li>\n<li"
        end

        listText += constructListItemText(sequentialList.items[sequentialList.items.length - 1])

        return listText
    end

    private
    def constructUpLevelSequentialListText(previousLevel, sequentialList, listTypeHash)
        listText = ""

        previousLevel.upto(sequentialList.level - 2) do |level|
            if listTypeHash[level] == KARAS::ListTypeUl
                listText += "\n<ul>\n<li>"
            else
                listText += "\n<ol>\n<li>"
            end
        end

        if sequentialList.level != 1
            listText += "\n"
        end

        if sequentialList.type == KARAS::ListTypeUl
            listText += "<ul>\n<li"
        else
            listText += "<ol>\n<li"
        end

        0.upto(sequentialList.items.length - 2) do |i|
            listText += constructListItemText(sequentialList.items[i]) + "</li>\n<li"
        end

        listText += constructListItemText(sequentialList.items[sequentialList.items.length - 1])

        return listText
    end

    private
    def constructDownLevelSequentialListText(previousLevel, sequentialList, listTypeHash)
        #Close previous list item.
        listText = "</li>\n"

        #Close previous level lists.
        previousLevel.downto(sequentialList.level + 1) do |level|
            if listTypeHash[level] == KARAS::ListTypeUl
                listText += "</ul>\n"
            else
                listText += "</ol>\n"
            end

            listText += "</li>\n"
        end

        #if current level's list type is different from previous same level's list type.
        if listTypeHash[sequentialList.level] != sequentialList.type
            #Note, it is important to update hash.
            if listTypeHash[sequentialList.level] == KARAS::ListTypeUl
                listText += "</ul>\n<ol>\n"
                listTypeHash[sequentialList.level] = KARAS::ListTypeOl
            else
                listText += "</ol>\n<ul>\n"
                listTypeHash[sequentialList.level] = KARAS::ListTypeUl
            end
        end

        0.upto(sequentialList.items.length - 2) do |i|
            listText += "<li" + constructListItemText(sequentialList.items[i]) + "</li>\n"
        end

        listText += "<li" + 
                    constructListItemText(sequentialList.items[sequentialList.items.length - 1])

        return listText
    end

    private
    def constructSameLevelSequentialListText(previousLevel, sequentialList, listTypeHash)
        #Close previous list item.
        listText = ""

        if listTypeHash[previousLevel] == KARAS::ListTypeUl
            listText += "</li>\n</ul>\n"
        else
            listText += "</li>\n</ol>\n"
        end

        if sequentialList.type == KARAS::ListTypeUl
            listText += "<ul>\n"
        else
            listText += "<ol>\n"
        end

        0.upto(sequentialList.items.length - 2) do |i|
            listText += "<li" + constructListItemText(sequentialList.items[i]) + "</li>\n"
        end

        listText += "<li" + 
                    constructListItemText(sequentialList.items[sequentialList.items.length - 1])

        #Note, it is important to update hash.
        listTypeHash[sequentialList.level] = sequentialList.type

        return listText
    end

    private
    def constructListItemText(listItemText)
        listItemText = KARAS::convertInlineMarkup(listItemText)
        listItemTexts = KARAS::splitOption(listItemText)

        if listItemTexts.length > 1
            listItemText = " value=\"" + listItemTexts[1] + "\">"
        else
            listItemText = ">"
        end

        listItemText += listItemTexts[0]

        return listItemText
    end

    private
    def constructListCloseText(previousLevel, listTypeHash)
        #Close previous list item.
        listText = "</li>\n"

        #Close all.
        previousLevel.downto(2) do |level|
            if listTypeHash[level] == KARAS::ListTypeUl
                listText += "</ul>\n"
            else
                listText += "</ol>\n"
            end

            listText += "</li>\n"
        end

        if listTypeHash[1] == KARAS::ListTypeUl
            listText += "</ul>"
        else
            listText += "</ol>"
        end

        return listText
    end

    public
    def convertDefList(text)
        #match group index.
        mgiAllText = 0
        mgiMarks = 1
        mgiMarkedupText = 2
        mgiNextMarks = 3
        mgiBreaks = 4

        match = nil
        nextMatchIndex = 0
        indexOfDefListText = 0
        defListIsOpen = false
        newText = ""

        while true
            match = KARAS::RegexDefList.match(text, nextMatchIndex)

            if match == nil
                break
            end

            if defListIsOpen == false
                defListIsOpen = true
                indexOfDefListText = match.begin(mgiAllText)
                newText = "<dl>\n"
            end

            if match[mgiMarks].length == 1
                newText += "<dt>" + 
                           KARAS::convertInlineMarkup(match[mgiMarkedupText].strip()) + 
                           "</dt>\n"
            else
                newText += "<dd>" + 
                           KARAS::convertInlineMarkup(match[mgiMarkedupText].strip()) + 
                           "</dd>\n"
            end

            if match[mgiNextMarks] == nil
                newText = KARAS::encloseWithLineBreak(newText + "</dl>")
                nextMatchIndex = indexOfDefListText + newText.length

                text = KARAS::removeAndInsertText(text,
                                                  indexOfDefListText,
                                                  match.begin(mgiAllText) + 
                                                  match[mgiAllText].length -
                                                  (match[mgiBreaks] == nil ? 0 : match[mgiBreaks].length) - 
                                                  indexOfDefListText,
                                                  KARAS::encloseWithLineBreak(newText))

                indexOfDefListText = 0
                defListIsOpen = false
                newText = ""
                next
            end

            nextMatchIndex = match.begin(mgiNextMarks);
        end

        return text
    end

    public
    def convertHeading(text)
        #match group index.
        mgiAllText = 0
        mgiMarks = 1
        mgiMarkedupText = 2
        mgiBreaks = 3

        maxLevelOfHeading = 6

        match = nil
        nextMatchIndex = 0

        while true
            match = KARAS::RegexHeading.match(text, nextMatchIndex)

            if match == nil
                break
            end

            newText = ""
            level = match[mgiMarks].length

            if level >= maxLevelOfHeading + 1
                newText = KARAS::encloseWithLineBreak("<hr>")
            else
                #Note, it is important to convert inline markups first,
                #to convert inline markup's options first.
                markedupText = KARAS::convertInlineMarkup(match[mgiMarkedupText])
                markedupTexts = KARAS::splitOption(markedupText)
                id = ""

                if markedupTexts.length > 1
                    id = " id=\"" + markedupTexts[1] + "\""
                end

                newText = "<h" + level.to_s() + id + ">" +
                          markedupTexts[0] + "</h" + level.to_s() + ">"
                newText = KARAS::encloseWithLineBreak(newText)
            end

            nextMatchIndex = match.begin(mgiAllText) + newText.length
            text = KARAS::removeAndInsertText(text,
                                              match.begin(mgiAllText),
                                              match[mgiAllText].length - match[mgiBreaks].length,
                                              KARAS::encloseWithLineBreak(newText))
        end

        return text
    end

    public
    def convertBlockLink(text)
        #match group index.
        mgiAllText = 0

        match = nil
        nextMatchIndex = 0

        while true
            match = KARAS::RegexBlockLink.match(text, nextMatchIndex)

            if match == nil
                break
            end

            newText = KARAS::convertInlineMarkup(match[mgiAllText]).strip()

            if textIsParagraph(newText)
                newText = "<p>" + newText + "</p>"
            end

            newText = KARAS::encloseWithLineBreak(newText)
            nextMatchIndex = match.begin(mgiAllText) + newText.length
            text = KARAS::removeAndInsertText(text,
                                              match.begin(mgiAllText),
                                              match[mgiAllText].length,
                                              KARAS::encloseWithLineBreak(newText))
        end

        return text
    end

    private
    def textIsParagraph(text)
        restText = text.gsub(KARAS::RegexLinkElement, "")
        restText = restText.strip()

        if restText.length == 0
            return false
        else
            return true
        end
    end

    public
    def convertParagraph(text)
        #match group index.
        mgiAllText = 0
        mgiMarkedupText = 1
        mgiLTMarks = 2

        #means \n\n length.
        lineBreaks = 2

        match = nil
        nextMatchIndex = 0

        while true
            match = KARAS::RegexParagraph.match(text, nextMatchIndex)

            if match == nil
                break
            end

            if match[mgiLTMarks].length == 1
                #Note, it is important to exclude line breaks (like \n).
                nextMatchIndex = match.begin(mgiAllText) + match[mgiMarkedupText].length
                next
            end

            markedupText = match[mgiMarkedupText].strip()

            if markedupText.length == 0
                nextMatchIndex = match.begin(mgiAllText) + match[mgiAllText].length
                next
            end

            newText = "<p>" + KARAS::convertInlineMarkup(markedupText) + "</p>\n"
            newText = KARAS::encloseWithLineBreak(newText)
            nextMatchIndex = match.begin(mgiAllText) + newText.length - lineBreaks
            text = KARAS::removeAndInsertText(text,
                                              match.begin(mgiAllText),
                                              match[mgiAllText].length,
                                              newText)
        end

        return text
    end

    public
    def reduceBlankLine(text)
        #match group index.
        mgiLineBreakCode = 0

        match = nil
        nextMatchIndex = 0

        while true
            match = KARAS::RegexBlankLine.match(text, nextMatchIndex)

            if match == nil
                break
            end

            text.slice!(match.begin(mgiLineBreakCode), match[mgiLineBreakCode].length)
            nextMatchIndex = match.begin(mgiLineBreakCode)
        end

        return text.strip()
    end

    public
    def reduceEscape(text)
        #match group index.
        mgiEscapes = 0

        match = nil
        nextMatchIndex = 0

        while true
            match = KARAS::RegexEscape.match(text, nextMatchIndex)

            if match == nil
                break
            end

            reduceLength = (match[mgiEscapes].length / 2.to_f()).round()
            text.slice!(match.begin(mgiEscapes), reduceLength)
            nextMatchIndex = match.begin(mgiEscapes) + match[mgiEscapes].length - reduceLength
        end

        return text
    end





    class InlineMarkupMatch
        attr_accessor :type
        attr_accessor :index
        attr_accessor :marks

        def initialize()
            @type = -1
            @index = -1
            @marks = ""
        end
    end

    public
    def convertInlineMarkup(text)
        #match group index.
        #mgiAllText = 0
        mgiEscapes = 1
        mgiMarks = 2

        matchStack = Array.new()
        match = nil
        nextMatchIndex = 0

        text = KARAS::convertLineBreak(text)

        while true
            match = KARAS::RegexInlineMarkup.match(text, nextMatchIndex)

            if match == nil
                break
            end

            if match[mgiEscapes].length % 2 == 1
                nextMatchIndex = match.begin(mgiMarks) + 1
                next
            end

            inlineMarkupMatch = constructInlineMarkupMatch(match.begin(mgiMarks), match[mgiMarks])
            preMatch = nil
            newText = ""
            closeMarks = ""

            if inlineMarkupMatch.type >= KARAS::InlineMarkupTypeLinkOpen
                #InlieneMarkupType*Close - 1 = InlineMarkupType*Open
                preMatch = getPreMatchedInlineMarkup(matchStack, inlineMarkupMatch.type - 1)
                nextMatchIndex, newText, closeMarks = 
                    handleLinkAndInlineGroupMatch(text,
                                                  preMatch,
                                                  inlineMarkupMatch,
                                                  matchStack,
                                                  nextMatchIndex,
                                                  newText,
                                                  closeMarks)
                if nextMatchIndex != -1
                    next
                end
            else
                preMatch = getPreMatchedInlineMarkup(matchStack, inlineMarkupMatch.type)
                nextMatchIndex, newText, closeMarks = 
                    handleBasicInlineMarkupMatch(text,
                                                 preMatch,
                                                 inlineMarkupMatch,
                                                 matchStack,
                                                 nextMatchIndex,
                                                 newText,
                                                 closeMarks)
                if nextMatchIndex != -1
                    next
                end
            end

            #It is important to trim close marks to exclude whitespace out of syntax.
            text = KARAS::removeAndInsertText(text,
                                              preMatch.index,
                                              inlineMarkupMatch.index +
                                              inlineMarkupMatch.marks.strip().length -
                                              preMatch.index,
                                              newText)
            nextMatchIndex = preMatch.index + newText.length - closeMarks.length
        end

        return text
    end

    public
    def convertLineBreak(text)
        #match group index.
        mgiAllText = 0
        mgiEscapes = 1
        mgiLineBreak = 2

        match = nil
        nextMatchIndex = 0

        while true
            match = KARAS::RegexLineBreak.match(text, nextMatchIndex)

            if match == nil
                break
            end

            if match[mgiEscapes].length % 2 == 1
                nextMatchIndex = match.begin(mgiAllText) + match[mgiAllText].length
                next
            end

            newText = "<br>\n"
            text = KARAS::removeAndInsertText(text,
                                              match.begin(mgiLineBreak),
                                              match[mgiLineBreak].length,
                                              newText)
            nextMatchIndex = match.begin(mgiLineBreak) + newText.length
        end

        return text
    end

    private
    def constructInlineMarkupMatch(index, marks)
        inlineMarkupMatch = InlineMarkupMatch.new()
        0.upto(KARAS::InlineMarkupSets.length - 1) do |i|
            if marks[0] == KARAS::InlineMarkupSets[i][0][0]
                inlineMarkupMatch.type = i
                inlineMarkupMatch.index = index
                inlineMarkupMatch.marks = marks
                break
            end
        end

        return inlineMarkupMatch
    end

    private
    def handleLinkAndInlineGroupMatch(text, openMatch, closeMatch, matchStack,
                                      nextMatchIndex, newText, closeMarks)
        if (closeMatch.type == KARAS::InlineMarkupTypeLinkOpen||
            closeMatch.type == KARAS::InlineMarkupTypeInlineGroupOpen)
            matchStack.unshift(closeMatch)
            nextMatchIndex = closeMatch.index + closeMatch.marks.length
            return nextMatchIndex, newText, closeMarks
        end

        if openMatch == nil
            nextMatchIndex = closeMatch.index + closeMatch.marks.length
            return nextMatchIndex, newText, closeMarks
        end

        markedupTextIndex = openMatch.index + openMatch.marks.length
        markedupText = text[markedupTextIndex, closeMatch.index - markedupTextIndex]
        openMarks = KARAS::removeWhiteSpace(openMatch.marks)
        closeMarks = KARAS::removeWhiteSpace(closeMatch.marks)

        if closeMatch.type == KARAS::InlineMarkupTypeLinkClose
            newText, openMarks, closeMarks = 
                constructLinkText(markedupText, newText, openMarks, closeMarks)
        else
            newText, openMarks, closeMarks = 
                constructInlineGroupText(markedupText, newText, openMarks, closeMarks)
        end

        if openMarks.length > 1
            openMatch.marks = openMarks
        else
            while true
                if matchStack.shift().type == openMatch.type
                    break
                end
            end
        end

        nextMatchIndex = -1
        return nextMatchIndex, newText, closeMarks
    end

    private
    def handleBasicInlineMarkupMatch(text, openMatch, closeMatch, matchStack,
                                     nextMatchIndex, newText, closeMarks)
        if openMatch == nil
            matchStack.unshift(closeMatch)
            nextMatchIndex = closeMatch.index + closeMatch.marks.length
            return nextMatchIndex, newText, closeMarks
        end

        markedupTextIndex = openMatch.index + openMatch.marks.length
        markedupText = text[markedupTextIndex, closeMatch.index - markedupTextIndex].strip()

        if (openMatch.type <= KARAS::InlineMarkupTypeSupRuby&& 
            openMatch.marks.length >= 3 && closeMatch.marks.length >= 3)
            newText, closeMarks = constructSecondInlineMarkupText(markedupText,
                                                                  openMatch,
                                                                  closeMatch,
                                                                  newText,
                                                                  closeMarks)
        else
            newText, closeMarks = constructFirstInlineMarkupText(markedupText,
                                                                 openMatch,
                                                                 closeMatch,
                                                                 newText,
                                                                 closeMarks)
        end

        while true
            if matchStack.shift().type == closeMatch.type
                break
            end
        end

        nextMatchIndex = -1
        return nextMatchIndex, newText, closeMarks
    end

    private
    def getPreMatchedInlineMarkup(matchStack, inlineMarkupType)
        #Note, check from latest match.
        0.upto(matchStack.length - 1) do |i|
            if matchStack[i].type == inlineMarkupType
                return matchStack[i]
            end
        end

        return nil
    end

    private
    def constructLinkText(markedupText, newText, openMarks, closeMarks)
        markedupTexts = KARAS::splitOption(markedupText)
        url = markedupTexts[0]

        if openMarks.length >= 5 && closeMarks.length >= 5
            newText = "<a href=\"" + url + "\">" + constructMediaText(url, markedupTexts) + "</a>"
        elsif openMarks.length >= 3 && closeMarks.length >= 3
            newText = constructMediaText(url, markedupTexts)
        else
            aliasText = ""

            if markedupTexts.length > 1
                aliasText = markedupTexts[1]
            else
                aliasText = url
            end

            newText = "<a href=\"" + url + "\">" + aliasText + "</a>"
        end

         markDiff = openMarks.length - closeMarks.length

        if markDiff > 0
            openMarks.slice!(markDiff..openMarks.length)
            closeMarks = ""
        else
            openMarks = ""
            closeMarks.slice!(-markDiff..closeMarks.length)
        end

        newText = openMarks + newText + closeMarks

        return newText, openMarks, closeMarks
    end

    private
    def constructMediaText(url, markedupTexts)
        mediaText = ""
        option = ""
        reservedAttribute = ""
        otherAttribute = ""
        embedAttribute = ""
        mediaType = KARAS::getMediaType(KARAS::getFileExtension(url))

        if markedupTexts.length > 1
            option = String.new(markedupTexts[1])

            reservedAttribute, otherAttribute, embedAttribute = 
                constructObjectAndEmbedAttributes(option, 
                                                  reservedAttribute,
                                                  otherAttribute,
                                                  embedAttribute)
            option = " " + markedupTexts[1]
        end

        case mediaType
            when KARAS::MediaTypeImage
                mediaText = "<img src=\"" + url + "\"" + option + ">"
            when KARAS::MediaTypeAudio
                mediaText = "<audio src=\"" + url + "\"" + option + ">" +
                            "<object data=\"" + url + "\"" + reservedAttribute + ">" +
                            otherAttribute + 
                            "<embed src=\"" + url + "\"" + embedAttribute +
                            "></object></audio>"
            when KARAS::MediaTypeVideo
                mediaText = "<video src=\"" + url + "\"" + option + ">" +
                            "<object data=\"" + url + "\"" + reservedAttribute + ">" + 
                            otherAttribute +
                            "<embed src=\"" + url + "\"" + embedAttribute +
                            "></object></video>"
            else
                mediaText = "<object data=\"" + url + "\"" + reservedAttribute + ">" +
                            otherAttribute +
                            "<embed src=\"" + url + "\"" + embedAttribute + "></object>"
        end

        return mediaText
    end

    public
    def getMediaType(extension)
        match = nil

        0.upto(KARAS::MediaExtensions.length - 1) do |i|
            match = KARAS::MediaExtensions[i].match(extension)

            if match != nil
                return i
            end
        end

        return KARAS::MediaTypeUnknown
    end

    public
    def getFileExtension(text)
        #match group index.
        #mgiAllText = 0
        mgiFileExtension = 1

        match = KARAS::RegexFileExtension.match(text)

        if match != nil
            return match[mgiFileExtension]
        else
            return ""
        end
    end

    private
    def constructObjectAndEmbedAttributes(option, reservedAttribute,
                                          otherAttribute, embedAttribute)
        parameterHash = constructParameterHash(option)

        parameterHash.keys.each do |name|
            if attributeIsReserved(name)
                reservedAttribute += name + "=\"" + parameterHash[name] + "\" "
            else
                otherAttribute += "<param name=\"" + name + 
                                  "\" value=\"" + parameterHash[name] + "\">"
            end

            embedAttribute += name + "=\"" + parameterHash[name] + "\" "
        end

        if reservedAttribute.length > 0
            reservedAttribute = " " + reservedAttribute.strip()
        end

        if embedAttribute.length > 0
            embedAttribute = " " + embedAttribute.strip()
        end

        return reservedAttribute, otherAttribute, embedAttribute
    end

    private
    def constructParameterHash(option)
        #match group index.
        mgiAllText = 0
        mgiName = 1
        mgiValue = 2

        parameterHash = Hash.new()
        match = nil
        nextMatchIndex = 0

        while true
            match = KARAS::RegexStringTypeAttribute.match(option)

            if match == nil
                break
            end

            parameterHash[match[mgiName]] = match[mgiValue]
            option.slice!(match.begin(mgiAllText), match[mgiAllText].length)
            nextMatchIndex = match.begin(mgiAllText)
        end

        logicalValues = option.split()

        logicalValues.each do |value|
            if value.length > 0
                parameterHash[value] = "true"
            end
        end

        return parameterHash
    end

    private
    def attributeIsReserved(attribute)
        KARAS::ReservedObjectAttributes.each do |reservedAttribute|
            if attribute.casecmp(reservedAttribute) == 0
                return true
            end
        end

        return false
    end

    private
    def constructInlineGroupText(markedupText, newText, openMarks, closeMarks)
        markedupTexts = KARAS::splitOption(markedupText)
        idClass = ""

        if openMarks.length >= 3 && closeMarks.length >= 3
            idClass = " id=\"";
        else
            idClass = " class=\""
        end

        if markedupTexts.length > 1
            idClass += markedupTexts[0] + "\""
            newText = markedupTexts[1]
        else
            newText = markedupTexts[0]
            idClass = ""
        end

         markDiff = openMarks.length - closeMarks.length

        if markDiff > 0
            openMarks.slice!(markDiff..openMarks.length)
            closeMarks = ""
        else
            openMarks = ""
            closeMarks.slice!(-markDiff..closeMarks.length)
        end

        newText = openMarks + "<span" + idClass + ">" + newText + "</span>" + closeMarks

        return newText, openMarks, closeMarks
    end

    private
    def constructSecondInlineMarkupText(markedupText, openMatch, closeMatch,
                                        newText, closeMarks)
        inlineMarkupSet = KARAS::InlineMarkupSets[openMatch.type]
        openMarks = String.new(openMatch.marks)
        openMarks.slice!(0, 3)
        closeMarks = String.new(closeMatch.marks)
        closeMarks.slice!(0, 3)
        openTag = ""
        closeTag = ""

        if openMatch.type == KARAS::InlineMarkupTypeSupRuby
            openTag = "<ruby>"
            closeTag = "</ruby>"
            markedupTexts = KARAS::splitOptions(markedupText)
            markedupText = markedupTexts[0]

            1.step(markedupTexts.length - 1, 2) do |i|
                markedupText += "<rp> (</rp><rt>" + markedupTexts[i] + "</rt><rp>) </rp>"

                if i + 1 < markedupTexts.length
                    markedupText += markedupTexts[i + 1]
                end
            end
        else
            openTag = "<" + inlineMarkupSet[2] + ">"
            closeTag = "</" + inlineMarkupSet[2] + ">"

            if openMatch.type == KARAS::InlineMarkupTypeDefAbbr
                openTag = "<" + inlineMarkupSet[1] + ">" + openTag
                closeTag = closeTag + "</" + inlineMarkupSet[1] + ">"
            end

            if openMatch.type == KARAS::InlineMarkupTypeKbdSamp ||
               openMatch.type == KARAS::InlineMarkupTypeVarCode
                markedupText = KARAS::escapeHtmlSpecialCharacters(markedupText)
            end
        end

        newText = openMarks + openTag + markedupText + closeTag + closeMarks
        return newText, closeMarks
    end

    private
    def constructFirstInlineMarkupText(markedupText, openMatch, closeMatch,
                                       newText, closeMarks)
        inlineMarkupSet = KARAS::InlineMarkupSets[openMatch.type]            
        openMarks = String.new(openMatch.marks)
        openMarks.slice!(0, 2)
        closeMarks = String.new(closeMatch.marks)
        closeMarks.slice!(0, 2)
        openTag = "<" + inlineMarkupSet[1] + ">"
        closeTag = "</" + inlineMarkupSet[1] + ">"

        if openMatch.type == KARAS::InlineMarkupTypeVarCode ||
           openMatch.type == KARAS::InlineMarkupTypeKbdSamp
            markedupText = KARAS::escapeHtmlSpecialCharacters(markedupText)
        end

        newText = openMarks + openTag + markedupText + closeTag + closeMarks
        return newText, closeMarks
    end
end