<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet 
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:str="http://exslt.org/strings"
   xmlns:exslt="http://exslt.org/common"
   xmlns:sccp="http://chan-sccp.net" version="1.0" exclude-result-prefixes="sccp"
>
  <xsl:param name="locales" select="'da, nl, de;q=0.9, en-gb;q=0.8, en;q=0.7'"/>
  <xsl:param name="translationFile" select="'./translations.xml'"/>
  <xsl:param name="locale"><xsl:call-template name="findLocale"/></xsl:param>
  
  <xsl:template name="findLocale">
    <xsl:param name="locales" select='$locales'/>
    <xsl:choose>
      <xsl:when test="document($translationFile)//sccp:translation and not($locales = '')">
        <xsl:variable name="translationNodeSet">
        <translations>
          <xsl:for-each select="str:tokenize($locales, ' -_,')">
            <xsl:variable name="testLocale" select="substring-before(concat(., ';'), ';')"/>
            <xsl:if test="$testLocale = 'en' or document($translationFile)//sccp:translation[@locale=$testLocale]">
            <translation><xsl:value-of select="$testLocale"/></translation>
            </xsl:if>
          </xsl:for-each>
        </translations>
        </xsl:variable>
        <xsl:for-each select="exslt:node-set($translationNodeSet)/translations/translation">
          <xsl:if test="position() = 1">
            <xsl:value-of select="."/>
          </xsl:if>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>en</xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="translate">
    <xsl:param name="key"/>
    <xsl:param name="locale" select='$locale'/>
    <xsl:choose>
      <xsl:when test="not(document($translationFile)//sccp:translation[@locale=$locale]) or $locale = 'en'">
        <xsl:value-of select="$key"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="document($translationFile)//sccp:translation[@locale=$locale]/entry[@key=$key]"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="/error">
    <xsl:if test="errorno &gt; 0">
      <CiscoIPPhoneText>
        <Title>An Error Occurred</Title>
        <Text><xsl:value-of select="errorno"/>: 
    <xsl:call-template name="translate"><xsl:with-param name="key" select="concat('errorno-',errorno)"/></xsl:call-template></Text>
      </CiscoIPPhoneText>
    </xsl:if>
  </xsl:template>

  <xsl:template match="/device">
    <xsl:choose>
      <xsl:when test="protocolversion &gt; 15">
        <CiscoIPPhoneIconFileMenu>
          <xsl:attribute name="appId">
            <xsl:value-of select="conference/appId"/>
          </xsl:attribute>
          <xsl:choose>
            <xsl:when test="conference/isLocked = 1">
              <Title IconIndex="5">
                <xsl:call-template name="translate">
                  <xsl:with-param name="key" select="'Conference'"/>
                </xsl:call-template> 
                <xsl:text> </xsl:text><xsl:value-of select="conference/id"/>
              </Title>
            </xsl:when>
            <xsl:otherwise>
              <Title IconIndex="4">
                <xsl:call-template name="translate">
                  <xsl:with-param name="key" select="'Conference'"/>
                </xsl:call-template> 
                <xsl:text> </xsl:text><xsl:value-of select="conference/id"/>
              </Title>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:apply-templates select="conference"/>
        </CiscoIPPhoneIconFileMenu>
      </xsl:when>
      <xsl:otherwise>
        <CiscoIPPhoneIconMenu>
          <Title>
            <xsl:call-template name="translate">
              <xsl:with-param name="key" select="'Conference'"/>
            </xsl:call-template> 
            <xsl:text> </xsl:text><xsl:value-of select="conference/id"/>
          </Title>
          <xsl:apply-templates select="conference"/>
        </CiscoIPPhoneIconMenu>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="conference">
    <xsl:variable name="protocolversion">
      <xsl:value-of select="protocolversion"/>
    </xsl:variable>
    <xsl:for-each select="participants/participant">
      <MenuItem>
        <xsl:choose>
          <xsl:when test="isModerator = 1">
            <xsl:choose>
              <xsl:when test="isMuted = 0">
                <IconIndex>0</IconIndex>
              </xsl:when>
              <xsl:otherwise>
                <IconIndex>1</IconIndex>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
            <xsl:choose>
              <xsl:when test="isMuted = 0">
                <IconIndex>2</IconIndex>
              </xsl:when>
              <xsl:otherwise>
                <IconIndex>3</IconIndex>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:otherwise>
        </xsl:choose>
        <Name><xsl:value-of select="id"/>: <xsl:value-of select="cid_name"/> (<xsl:value-of select="extension"/>)</Name>
        <!--<URL>UserCallData:<xsl:value-of select="../../appId"/>:<xsl:value-of select="lineInstance"/>:<xsl:value-of select="callReference"/>:<xsl:value-of select="../../transactionId"/>:<xsl:value-of select="../../id"/></URL>-->
        <URL>QueryStringParam:partId=<xsl:value-of select="id"/></URL>
      </MenuItem>
    </xsl:for-each>
    <SoftKeyItem>
      <Name>
        <xsl:call-template name="translate">
          <xsl:with-param name="key" select="'EndConf'"/>
        </xsl:call-template>
      </Name>
      <Position>1</Position>
      <URL><xsl:value-of select="../server_url"/>?handler=<xsl:value-of select="../handler"/>&amp;<xsl:value-of select="../uri"/>&amp;transactionId=<xsl:value-of select="transactionId"/>&amp;action=ENDCONF</URL>
    </SoftKeyItem>
    <SoftKeyItem>
      <Name>
        <xsl:call-template name="translate">
          <xsl:with-param name="key" select="'Mute'"/>
        </xsl:call-template>
      </Name>
      <Position>2</Position>
      <URL><xsl:value-of select="../server_url"/>?handler=<xsl:value-of select="../handler"/>&amp;<xsl:value-of select="../uri"/>&amp;transactionId=<xsl:value-of select="transactionId"/>&amp;action=MUTE</URL>
    </SoftKeyItem>
    <SoftKeyItem>
      <Name>
        <xsl:call-template name="translate">
          <xsl:with-param name="key" select="'Kick'"/>
        </xsl:call-template>
      </Name>
      <Position>3</Position>
      <URL><xsl:value-of select="../server_url"/>?handler=<xsl:value-of select="../handler"/>&amp;<xsl:value-of select="../uri"/>&amp;transactionId=<xsl:value-of select="transactionId"/>&amp;action=KICK</URL>
    </SoftKeyItem>
    <SoftKeyItem>
      <Name>
        <xsl:call-template name="translate">
          <xsl:with-param name="key" select="'Exit'"/>
        </xsl:call-template>
      </Name>
      <Position>4</Position>
      <URL>SoftKey:Exit</URL>
    </SoftKeyItem>
    <SoftKeyItem>
      <Name>
        <xsl:call-template name="translate">
          <xsl:with-param name="key" select="'Moderate'"/>
        </xsl:call-template>
      </Name>
      <Position>5</Position>
      <URL><xsl:value-of select="../server_url"/>?handler=<xsl:value-of select="../handler"/>&amp;<xsl:value-of select="../uri"/>&amp;transactionId=<xsl:value-of select="transactionId"/>&amp;action=MODERATE</URL>
    </SoftKeyItem>
    <SoftKeyItem>
      <Name>
        <xsl:call-template name="translate">
          <xsl:with-param name="key" select="'Invite'"/>
        </xsl:call-template>
      </Name>
      <Position>6</Position>
      <URL><xsl:value-of select="../server_url"/>?handler=confinvite&amp;<xsl:value-of select="../uri"/>&amp;transactionId=<xsl:value-of select="transactionId"/>&amp;action=INVITE</URL>
    </SoftKeyItem>
    <xsl:choose>
      <xsl:when test="../protocolversion &gt; 15">
        <IconItem>
          <Index>0</Index>
          <URL>Resource:Icon.Connected</URL>
        </IconItem>
        <IconItem>
          <Index>1</Index>
          <URL>Resource:AnimatedIcon.Hold</URL>
        </IconItem>
        <IconItem>
          <Index>2</Index>
          <URL>Resource:AnimatedIcon.StreamRxTx</URL>
        </IconItem>
        <IconItem>
          <Index>3</Index>
          <URL>Resource:AnimatedIcon.Hold</URL>
        </IconItem>
        <IconItem>
          <Index>4</Index>
          <URL>Resource:Icon.Speaker</URL>
        </IconItem>
        <IconItem>
          <Index>5</Index>
          <URL>Resource:Icon.SecureCall</URL>
        </IconItem>
      </xsl:when>
      <xsl:otherwise>
        <IconItem>
          <Index>0</Index>
          <Height>10</Height>
          <Width>16</Width>
          <Depth>2</Depth>
          <Data>000F0000C03F3000C03FF000C03FF003000FF00FFCFFF30FFCFFF303CC3FF300CC3F330000000000</Data>
        </IconItem>
        <IconItem>
          <Index>1</Index>
          <Height>10</Height>
          <Width>16</Width>
          <Depth>2</Depth>
          <Data>000F0000C03FF03CC03FF03CC03FF03C000FF03CFCFFF33CFCFFF33CCC3FF33CCC3FF33C00000000</Data>
        </IconItem>
        <IconItem>
          <Index>2</Index>
          <Height>10</Height>
          <Width>16</Width>
          <Depth>2</Depth>
          <Data>000F0000C0303000C030F000C030F003000FF00FFCF0F30F0C00F303CC30F300CC30330000000000</Data>
        </IconItem>
        <IconItem>
          <Index>3</Index>
          <Height>10</Height>
          <Width>16</Width>
          <Depth>2</Depth>
          <Data>000F0000C030F03CC030F03CC030F03C000FF03CFCF0F33C0C00F33CCC30F33CCC30F33C00000000</Data>
        </IconItem>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
