return function(env, echo)
	local io = require 'ext.io'
	local string = require 'ext.string'

	local legend = {
		{name='keyword', symbols=[[
and       break     do        else      elseif    end
false     for       function  goto      if        in
local     nil       not       or        repeat    return
then      true      until     while
]]},
		{name='symbol', symbols=[[
+     -     *     /     %     ^     #
==    ~=    <=    >=    <     >     =
(     )     {     }     [     ]     ::
;     :     ,     .     ..    ...

' " \\
]]},
		{name='global', symbols=[[
_G _VERSION assert bit32 collectgarbage coroutine debug dofile error getmetatable io ipairs js load loadfile loadstring math module next os package pairs pcall print rawequal rawget rawlen rawset require select setmetatable string t table tonumber tostring type unpack xpcall
]]},
		{name='string', symbols=[[
string.byte string.char string.dump string.find string.format string.gmatch string.gsub string.len string.lower string.match string.rep string.reverse string.sub string.upper 
]]},
		{name='table', symbols=[[
table.concat table.insert table.maxn table.pack table.remove table.sort table.unpack
]]},
		{name='math', symbols=[[
math.abs math.acos math.asin math.atan math.atan2 math.ceil math.cos math.cosh math.deg math.exp math.floor math.fmod math.frexp math.huge math.ldexp math.log math.log10 math.max math.min math.modf math.pi math.pow math.rad math.random math.randomseed math.sin math.sinh math.sqrt math.tan math.tanh 
]]},
		{name='bit32', symbols=[[
bit32.arshift bit32.band bit32.bnot bit32.bor bit32.btest bit32.bxor bit32.extract bit32.lrotate bit32.lshift bit32.replace bit32.rrotate bit32.rshift 
]]},
		{name='io', symbols=[[
io.close io.flush io.input io.lines io.open io.output io.popen io.read io.stderr io.stdin io.stdout io.tmpfile io.type io.write 
seek setvbuf 
]]},
		{name='os', symbols=[[
os.clock os.date os.difftime os.execute os.exit os.getenv os.remove os.rename os.setlocale os.time os.tmpname 
]]},
		{name='coroutine', symbols=[[
coroutine.create coroutine.resume coroutine.running coroutine.status coroutine.wrap coroutine.yield 
]]},
		{name='package', symbols=[[
package.config package.cpath package.loaded package.loaders package.loadlib package.path package.preload package.searchers package.searchpath package.seeall 
]]},
		{name='debug', symbols=[[
debug.debug debug.gethook debug.getinfo debug.getlocal debug.getmetatable debug.getregistry debug.getupvalue debug.getuservalue debug.sethook debug.setlocal debug.setmetatable debug.setupvalue debug.setuservalue debug.traceback debug.upvalueid debug.upvaluejoin 
]]},
		{name='meta', symbols=[[
__add __sub __mul __div __mod __pow __unm __concat __len __eq __lt __le __index __newindex __call __tostring __metatable __gc 
]]},
	}

	for i,l in ipairs(legend) do
		l.symbols = string.split(string.trim(l.symbols), '%s+')
	end

	local s = io.readfile'emoji-lua/emojis.txt'
--echo(s)
	local d = string.split(s, '\n')
	if d[#d] == '' then d[#d] = nil end
	math.randomseed(os.time())
	local allpairs = {}
	for i,l in ipairs(legend) do
		l.emojis = {}
		for j,sym in ipairs(l.symbols) do
			local emoji = table.remove(d, math.random(#d))
			table.insert(l.emojis, emoji)
			table.insert(allpairs, {sym, emoji})
		end
	end
	table.sort(allpairs, function(a,b)
		return #a[2] > #b[2]
	end)
	echo[[
<script type='text/javascript' src='/js/lua.vm-util.js.lua'></script>
<style type='text/css'>

.tooltip {
	display: inline-block;
	border-bottom: 1px dotted black;
}

.tooltip .tooltiptext {
	visibility: hidden;
	width: 120px;
	text-align: center;
	background-color: white;
	color: black;
	border: 1px solid black;
	border-radius: 6px;
	padding: 5px 0;
	position: absolute;
	z-index: 1;
}

.tooltip:hover .tooltiptext {
	visibility: visible;
}

</style>
<div class="entry">
	This is just the language Lua warpped in Emoji.
	This is the lazy version, where I just regex the emojis into keywords.
	Maybe later I'll modify my <a href='https://github.com/thenumbernine/lua-parser'>Lua parser in Lua</a> to recognize the emojis
	so you can harmlessly embed the emojis within strings.<br>
</div>
<div>
	<a href='https://www.lua.org/manual/5.2/manual.html'>Lua 5.2 Manual</a><br>
	<table>
		<tr>
]]
	for i,l in ipairs(legend) do
		echo('<td>'..l.name..'</td>\n')
	end
echo[[
		</tr>
		<tr>
]]
	for i,l in ipairs(legend) do
		echo'<td>'
		for j,e in ipairs(l.emojis) do
			echo('<span class="tooltip">')
			echo('<a onclick=\'addchar("'..e..'");\'>'..e..'</a>')
			echo('<span class="tooltiptext">'..l.symbols[j]..'</span>')
			echo('</span>')
		end
		echo'</td>'
	end
	echo[[
		</tr>
	</table>
</div>

<div id='lua-vm-container' class='entry'></div>
<script type='text/javascript'>
var ThisEmbeddedLuaInterpreter = makeClass({
	super : EmbeddedLuaInterpreter,
	execute : function(s) {
		Lua.execute(s);
	},
	executeAndPrint : function(s) {
		Module.print('> '+s);
]]
	for _,p in ipairs(allpairs) do
		local k,e = p[1], p[2]
		if k == "'" then 
			k = "\\'" 
		elseif k == '"' then
		else
			k = ' '..k..' '
		end
		echo([[
		s = s.replace(/]]..e..[[/g, ']]..k..[[');
]])
	end
echo[[
		//Module.print('> '+s);
		this.execute(s);
	}
});
var interpretter = new ThisEmbeddedLuaInterpreter({
	id : 'lua-vm-container',
	packages : ['ext'],
	autoLaunch : true,
	done : function() {
		//output.empty();
		Lua.execute("package.path = package.path .. ';./?/init.lua'");
	}
});
function addchar(c) {
	interpretter.input[0].value += c;
}
</script>
]]
end
