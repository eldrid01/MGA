<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="html" indent="yes"/>
<xsl:variable name="alignedFractionThreshold">0.025</xsl:variable>
<xsl:template match="/">
<html>
<head>
<title>Multi-Genome Alignment Report
	<xsl:choose>
		<xsl:when test="MultiGenomeAlignmentSummaries/Properties/Property[@name='Run name']">
			&#8211; <xsl:value-of select="MultiGenomeAlignmentSummaries/Properties/Property[@name='Run name']/@value"/>
		</xsl:when>
		<xsl:when test="MultiGenomeAlignmentSummaries/RunId">
			&#8211; Run <xsl:value-of select="MultiGenomeAlignmentSummaries/RunId"/>
		</xsl:when>
	</xsl:choose>
</title>
</head>
<body>

<h2>Multi-Genome Alignment Report</h2>

<xsl:variable name="datasetCount"><xsl:value-of select="count(MultiGenomeAlignmentSummaries/MultiGenomeAlignmentSummary)"/></xsl:variable>

<!-- Variables taken from results for first dataset -->

<xsl:variable name="referenceGenomeCount"><xsl:value-of select="count(MultiGenomeAlignmentSummaries/ReferenceGenomes/ReferenceGenome)"/></xsl:variable>

<xsl:variable name="trimLength"><xsl:value-of select="MultiGenomeAlignmentSummaries/TrimLength"/></xsl:variable>

<xsl:variable name="totalSequenceCount"><xsl:value-of select="sum(MultiGenomeAlignmentSummaries/MultiGenomeAlignmentSummary/SequenceCount)"/></xsl:variable>

<xsl:variable name="yieldMultiplier">
	<xsl:choose>
		<xsl:when test="MultiGenomeAlignmentSummaries/EndType = 'Paired End'">2</xsl:when>
		<xsl:otherwise>1</xsl:otherwise>
	</xsl:choose>
</xsl:variable>

<table>
	<xsl:for-each select="MultiGenomeAlignmentSummaries/Properties/Property[@name]">
		<tr>
			<td><xsl:value-of select="@name"/>:</td>
			<td><xsl:value-of select="@value"/></td>
		</tr>
	</xsl:for-each>
	<xsl:variable name="totalYield"><xsl:value-of select="$yieldMultiplier * $totalSequenceCount * MultiGenomeAlignmentSummaries/Properties/Property[@name='Cycles']/@value div 1000000000"/></xsl:variable>
	<xsl:if test="$totalYield != 'NaN'">
		<tr>
			<td>Yield (Gbases):</td>
			<td><xsl:value-of select="format-number($totalYield, '0.00')"/></td>
		</tr>
	</xsl:if>
	<tr>
		<td>Total sequences:</td>
		<td><xsl:value-of select="format-number($totalSequenceCount, '###,###')"/></td>
	</tr>
</table>

<p/>

<xsl:if test="MultiGenomeAlignmentSummaries/Image">
	<img>
		<xsl:attribute name="src">
				<xsl:value-of select="MultiGenomeAlignmentSummaries/Image"/>
		</xsl:attribute>
	</img>
	<br/>
</xsl:if>

Sequences were sampled<xsl:if test="$trimLength != ''">,
trimmed to <xsl:value-of select="$trimLength"/> bases</xsl:if>
and mapped to <xsl:value-of select="$referenceGenomeCount"/>
reference genomes (see <a href="#referenceGenomes">list</a> below) using Bowtie.
<p/>
The reference genomes are sorted in the tables below according to how many
sequences have been mapped. Sequence reads often align to multiple
genomes. Each sequence is assigned to the genome with the most aligned sequences.
The 'assigned' column contains the number of sequences that align to that
particular genome but not also to another genome listed higher in the table,
i.e. with more overall matches.
<p/>
Sequences containing adapters were found by ungapped alignment using Exonerate.
<p/>

Datasets:
<xsl:for-each select="MultiGenomeAlignmentSummaries/MultiGenomeAlignmentSummary">
	<xsl:sort select="DatasetId"/>
	<xsl:variable name="datasetId"><xsl:value-of select="DatasetId"/></xsl:variable>
	<a href="#{$datasetId}"><xsl:value-of select="DatasetId"/></a> |
</xsl:for-each>
<p/>

<xsl:for-each select="MultiGenomeAlignmentSummaries/MultiGenomeAlignmentSummary">
	<xsl:sort select="DatasetId"/>

	<hr/>
	<xsl:variable name="datasetId"><xsl:value-of select="DatasetId"/></xsl:variable>
	<h3 id="{$datasetId}"><xsl:value-of select="DatasetId"/></h3>

	<table>
		<xsl:variable name="yield"><xsl:value-of select="$yieldMultiplier * SequenceCount * ../Properties/Property[@name='Cycles']/@value div 1000000000"/></xsl:variable>
		<xsl:if test="$yield != 'NaN'">
			<tr>
				<td>Yield (Gbases):</td>
				<td><xsl:value-of select="format-number($yield, '0.00')"/></td>
			</tr>
		</xsl:if>
		<tr>
			<td>Sequences:</td>
			<xsl:choose>
				<xsl:when test="SequenceCount &gt; 0">
					<td align="right"><xsl:value-of select="format-number(SequenceCount, '###,###')"/></td>
				</xsl:when>
				<xsl:otherwise>
					<td align="left"><xsl:value-of select="SequenceCount"/></td>
				</xsl:otherwise>
			</xsl:choose>
		</tr>
		<xsl:if test="SampledCount &gt; 0">
			<tr>
				<td>Sampled:</td>
				<td><xsl:value-of select="format-number(SampledCount, '###,###')"/></td>
			</tr>
		</xsl:if>
	</table>
	<p/>

	<xsl:if test="SampledCount &gt; 0">

		<xsl:variable name="otherCount"><xsl:value-of select="sum(AlignmentSummaries/AlignmentSummary[not(ReferenceGenome/@name = ../../Samples/Sample/Properties/Property[@name='Species']/@value) and AlignedCount div ../../SampledCount &lt; $alignedFractionThreshold]/AssignedCount)"/></xsl:variable>
		<xsl:variable name="otherNumber"><xsl:value-of select="count(AlignmentSummaries/AlignmentSummary[not(ReferenceGenome/@name = ../../Samples/Sample/Properties/Property[@name='Species']/@value) and AlignedCount div ../../SampledCount &lt; $alignedFractionThreshold]/AssignedCount)"/></xsl:variable>

		<table border="2" cellpadding="5" style="border-collapse: collapse">

			<tr align="left">
				<th>Reference ID</th>
				<th>Species/Reference Genome</th>
				<th>Aligned</th>
				<th>Aligned %</th>
				<th>Error rate</th>
				<th>Assigned</th>
				<th>Assigned %</th>
			</tr>

			<xsl:for-each select="AlignmentSummaries/AlignmentSummary">
				<xsl:sort select="AssignedCount" data-type="number" order="descending"/>

				<xsl:variable name="alignedFraction"><xsl:value-of select="AlignedCount div ../../SampledCount"/></xsl:variable>
				<xsl:variable name="assignedFraction"><xsl:value-of select="AssignedCount div ../../SampledCount"/></xsl:variable>

				<xsl:if test="$otherNumber &lt; 2 or $alignedFraction &gt; $alignedFractionThreshold or ReferenceGenome/@name = ../../Samples/Sample/Properties/Property[@name='Species']/@value">

				<tr>
					<xsl:choose>
						<xsl:when test="ReferenceGenome/@name = ../../Samples/Sample/Properties[Property[@name='Control' and @value='Yes' ]]/Property[@name='Species']/@value">
							<xsl:attribute name="style">
								background-color:
								<xsl:choose>
									<xsl:when test="$alignedFraction &gt; 0.15">#FFA000</xsl:when>
									<xsl:when test="$alignedFraction &gt; 0.10">#FFB400</xsl:when>
									<xsl:when test="$alignedFraction &gt; 0.05">#FFC800</xsl:when>
									<xsl:otherwise>#FFDC00</xsl:otherwise>
								</xsl:choose>
								;
							</xsl:attribute>
						</xsl:when>
						<xsl:when test="ReferenceGenome/@name = ../../Samples/Sample/Properties/Property[@name='Species']/@value">
							<xsl:attribute name="style">
								background-color:
								<xsl:choose>
									<xsl:when test="$alignedFraction &gt; 0.8">#58FA58</xsl:when>
									<xsl:when test="$alignedFraction &gt; 0.6">#81F781</xsl:when>
									<xsl:when test="$alignedFraction &gt; 0.4">#A9F5A9</xsl:when>
									<xsl:when test="$alignedFraction &gt; 0.2">#CEF6CE</xsl:when>
									<xsl:otherwise>#E0F8E0</xsl:otherwise>
								</xsl:choose>
								;
							</xsl:attribute>
						</xsl:when>
						<xsl:when test="../../Samples/Sample/Properties/Property[@name='Species']/@value = 'Other'"/>
						<xsl:when test="../../Samples/Sample/Properties/Property[@name='Species']/@value = 'other'"/>
						<xsl:when test="../../Samples/Sample/Properties/Property[@name='Species']/@value != ''">
							<xsl:attribute name="style">
								background-color:
								<xsl:choose>
									<xsl:when test="$assignedFraction &gt; 0.4">#FE2E2E</xsl:when>
									<xsl:when test="$assignedFraction &gt; 0.3">#FA5858</xsl:when>
									<xsl:when test="$assignedFraction &gt; 0.2">#F78181</xsl:when>
									<xsl:when test="$assignedFraction &gt; 0.1">#F5A9A9</xsl:when>
									<xsl:when test="$assignedFraction &gt; 0.05">#F6CECE</xsl:when>
								</xsl:choose>
								;
							</xsl:attribute>
						</xsl:when>
					</xsl:choose>

					<td><xsl:value-of select="ReferenceGenome/@id"/></td>
					<td><xsl:value-of select="ReferenceGenome/@name"/></td>
					<td align="right">
						<xsl:value-of select="AlignedCount"/>
					</td>
					<td align="right">
						<xsl:if test="AlignedCount &gt; 0">
							<xsl:value-of select="format-number($alignedFraction, '0.0%')"/>
						</xsl:if>
					</td>
					<td align="right">
						<xsl:if test="AlignedCount &gt; 0 and ErrorRate != ''">
							<xsl:value-of select="format-number(ErrorRate, '0.00%')"/>
						</xsl:if>
					</td>
					<td align="right">
						<xsl:if test="AssignedCount &gt; 0">
							<xsl:value-of select="AssignedCount"/>
						</xsl:if>
					</td>
					<td align="right">
						<xsl:if test="AssignedCount &gt; 0">
							<xsl:value-of select="format-number($assignedFraction, '0.0%')"/>
						</xsl:if>
					</td>
				</tr>

				</xsl:if>
			</xsl:for-each>

			<xsl:if test="$otherNumber &gt; 1">
				<tr>
					<td>Other</td>
					<td><xsl:value-of select="$otherNumber"/> others</td>
					<td/>
					<td/>
					<td/>
					<td align="right">
						<xsl:value-of select="$otherCount"/>
					</td>
					<td align="right">
						<xsl:value-of select="format-number($otherCount div SampledCount, '0.0%')"/>
					</td>
				</tr>
			</xsl:if>

			<tr>
				<xsl:variable name="unmappedFraction"><xsl:value-of select="UnmappedCount div SampledCount"/></xsl:variable>
				<xsl:choose>
					<xsl:when test="Samples/Sample/Properties/Property[@name='Experiment type']/@value = 'sRNA'"/>
					<xsl:when test="Samples/Sample/Properties/Property[@name='Species']/@value = 'Other'"/>
					<xsl:when test="Samples/Sample/Properties/Property[@name='Species']/@value = 'other'"/>
					<xsl:when test="Samples/Sample/Properties/Property[@name='Species']/@value != ''">
						<xsl:attribute name="style">
							background-color:
							<xsl:choose>
								<xsl:when test="$unmappedFraction &gt; 0.4">#FE2E2E</xsl:when>
								<xsl:when test="$unmappedFraction &gt; 0.3">#FA5858</xsl:when>
								<xsl:when test="$unmappedFraction &gt; 0.2">#F78181</xsl:when>
								<xsl:when test="$unmappedFraction &gt; 0.1">#F5A9A9</xsl:when>
							</xsl:choose>
							;
						</xsl:attribute>
					</xsl:when>
				</xsl:choose>
				<td>Unmapped</td>
				<td></td>
				<td align="right"><xsl:value-of select="UnmappedCount"/></td>
				<td align="right"><xsl:value-of select="format-number($unmappedFraction, '0.0%')"/></td>
				<td></td>
				<td></td>
				<td></td>
			</tr>

			<tr>
				<xsl:variable name="adapterFraction"><xsl:value-of select="AdapterCount div SampledCount"/></xsl:variable>
				<xsl:choose>
					<xsl:when test="Samples/Sample/Properties/Property[@name='Experiment type']/@value = 'sRNA'"/>
					<xsl:otherwise>
						<xsl:attribute name="style">
							background-color:
							<xsl:choose>
								<xsl:when test="$adapterFraction &gt; 0.4">#FE2E2E</xsl:when>
								<xsl:when test="$adapterFraction &gt; 0.3">#FA5858</xsl:when>
								<xsl:when test="$adapterFraction &gt; 0.2">#F78181</xsl:when>
								<xsl:when test="$adapterFraction &gt; 0.1">#F5A9A9</xsl:when>
							</xsl:choose>
							;
						</xsl:attribute>
					</xsl:otherwise>
				</xsl:choose>
				<td>Adapter</td>
				<td></td>
				<td align="right"><xsl:value-of select="AdapterCount"/></td>
				<td align="right"><xsl:value-of select="format-number($adapterFraction, '0.0%')"/></td>
				<td></td>
				<td></td>
				<td></td>
			</tr>

		</table>

	</xsl:if>

	<!--
		Assumes that sample properties are consistent for each sample in the dataset,
		i.e. have the same names and in the same order.
	-->
	<xsl:if test="Samples/Sample/Properties/Property[@name]">
		<br/>
		<table>
			<tr>
				<td>Sample details</td>
			</tr>
		</table>
		<br/>
		<table border="1" cellpadding="5" style="border-collapse: collapse">
			<tr align="left">
				<xsl:for-each select="Samples/Sample[1]/Properties/Property[@name]">
					<th><xsl:value-of select="@name"/></th>
				</xsl:for-each>
			</tr>
			<xsl:for-each select="Samples/Sample">
				<tr>
					<xsl:for-each select="Properties/Property[@name]">
						<td><xsl:value-of select="@value"/></td>
					</xsl:for-each>
				</tr>
			</xsl:for-each>
		</table>
	</xsl:if>

</xsl:for-each>

<hr/>

<h3 id="referenceGenomes">Reference Genomes</h3>

Sequences were aligned to the following reference genomes
(<xsl:value-of select="$referenceGenomeCount"/> in total)

<ul style="list-style-type: circle">
	<xsl:for-each select="MultiGenomeAlignmentSummaries/ReferenceGenomes/ReferenceGenome">
		<xsl:sort select="@name"/>
		<li>
			<xsl:value-of select="@name"/>
		</li>
	</xsl:for-each>
</ul>

</body>
</html>

</xsl:template>
</xsl:stylesheet>

