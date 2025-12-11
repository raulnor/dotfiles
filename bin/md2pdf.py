#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = [
#   "reportlab",
# ]
# ///

"""
Convert D&D session markdown files to two-column PDFs.

Usage:
    python md2pdf.py input.md [output.pdf]
    
If output is not specified, it will use the input filename with .pdf extension.
"""

import re
import sys
import os
from reportlab.lib.pagesizes import letter
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.units import inch
from reportlab.lib import colors
from reportlab.platypus import (
    BaseDocTemplate, PageTemplate, Frame, Paragraph, Spacer,
    Table, TableStyle, KeepTogether
)
from reportlab.lib.enums import TA_LEFT, TA_CENTER, TA_JUSTIFY

# Page setup
PAGE_WIDTH, PAGE_HEIGHT = letter
MARGIN = 0.5 * inch
COLUMN_GAP = 0.25 * inch
COLUMN_WIDTH = (PAGE_WIDTH - 2 * MARGIN - COLUMN_GAP) / 2


def create_styles():
    """Create custom paragraph styles."""
    styles = getSampleStyleSheet()

    # Title style (# level)
    styles.add(ParagraphStyle(
        name='DocTitle',
        parent=styles['Title'],
        fontSize=18,
        spaceAfter=12,
        textColor=colors.HexColor('#2c3e50'),
        alignment=TA_CENTER
    ))

    # Section header (## level)
    styles.add(ParagraphStyle(
        name='SectionHeader',
        parent=styles['Heading1'],
        fontSize=14,
        spaceBefore=14,
        spaceAfter=6,
        textColor=colors.HexColor('#8b0000'),
    ))

    # Subsection header (### level)
    styles.add(ParagraphStyle(
        name='SubsectionHeader',
        parent=styles['Heading2'],
        fontSize=11,
        spaceBefore=10,
        spaceAfter=4,
        textColor=colors.HexColor('#2c3e50'),
    ))

    # Sub-subsection header (#### level)
    styles.add(ParagraphStyle(
        name='SubSubsectionHeader',
        parent=styles['Heading3'],
        fontSize=10,
        spaceBefore=8,
        spaceAfter=3,
        textColor=colors.HexColor('#34495e'),
    ))

    # Body text
    styles.add(ParagraphStyle(
        name='Body',
        parent=styles['Normal'],
        fontSize=9,
        leading=11,
        spaceAfter=6,
        alignment=TA_JUSTIFY
    ))

    # Blockquote style
    styles.add(ParagraphStyle(
        name='BlockQuote',
        parent=styles['Normal'],
        fontSize=9,
        leading=11,
        leftIndent=10,
        rightIndent=10,
        spaceAfter=6,
        spaceBefore=6,
        textColor=colors.HexColor('#444444'),
        backColor=colors.HexColor('#f5f5f5'),
        borderPadding=6,
    ))

    # List item style
    styles.add(ParagraphStyle(
        name='ListItem',
        parent=styles['Normal'],
        fontSize=9,
        leading=11,
        leftIndent=12,
        spaceAfter=3,
        bulletIndent=0,
    ))

    # Code/monospace style
    styles.add(ParagraphStyle(
        name='CodeBlock',
        parent=styles['Normal'],
        fontName='Courier',
        fontSize=8,
        leading=10,
        leftIndent=10,
        spaceAfter=6,
        spaceBefore=6,
        backColor=colors.HexColor('#f0f0f0'),
    ))

    return styles


def parse_frontmatter(content):
    """Remove YAML frontmatter if present."""
    if content.startswith('---'):
        end = content.find('---', 3)
        if end != -1:
            return content[end + 3:].strip()
    return content


def convert_inline_formatting(text):
    """Convert markdown inline formatting to reportlab XML tags."""
    # Escape special XML characters first (but not our markdown)
    text = text.replace('&', '&amp;')
    text = text.replace('<', '&lt;')
    text = text.replace('>', '&gt;')
    
    # Bold: **text** or __text__
    text = re.sub(r'\*\*(.+?)\*\*', r'<b>\1</b>', text)
    text = re.sub(r'__(.+?)__', r'<b>\1</b>', text)
    
    # Italic: *text* or _text_
    text = re.sub(r'\*(.+?)\*', r'<i>\1</i>', text)
    text = re.sub(r'(?<!\w)_(.+?)_(?!\w)', r'<i>\1</i>', text)
    
    # Inline code: `text`
    text = re.sub(r'`(.+?)`', r'<font face="Courier" size="8">\1</font>', text)
    
    # Links: [text](url) - just show the text
    text = re.sub(r'\[([^\]]+)\]\([^)]+\)', r'\1', text)
    
    # Wiki links: [[text]] or [[text|display]]
    text = re.sub(r'\[\[([^|\]]+)\|([^\]]+)\]\]', r'\2', text)
    text = re.sub(r'\[\[([^\]]+)\]\]', r'\1', text)
    
    return text


def parse_markdown(content):
    """Parse markdown content into structured elements."""
    content = parse_frontmatter(content)
    lines = content.split('\n')
    
    elements = []
    current_quote = []
    in_quote = False
    in_table = False
    table_rows = []
    title = None
    
    i = 0
    while i < len(lines):
        line = lines[i]
        stripped = line.strip()
        
        # Handle blockquotes
        if stripped.startswith('>'):
            quote_text = stripped[1:].strip()
            current_quote.append(quote_text)
            in_quote = True
            i += 1
            continue
        elif in_quote and stripped == '':
            # Check if next non-empty line is also a quote
            j = i + 1
            while j < len(lines) and lines[j].strip() == '':
                j += 1
            if j < len(lines) and lines[j].strip().startswith('>'):
                current_quote.append('')  # Preserve paragraph break
                i += 1
                continue
            else:
                # End of quote block
                elements.append(('quote', '\n'.join(current_quote)))
                current_quote = []
                in_quote = False
                i += 1
                continue
        elif in_quote:
            # End of quote block
            elements.append(('quote', '\n'.join(current_quote)))
            current_quote = []
            in_quote = False
            # Don't increment - process this line normally
        
        # Handle tables
        if '|' in stripped and not stripped.startswith('|--'):
            if not in_table:
                in_table = True
                table_rows = []
            
            # Parse table row
            cells = [c.strip() for c in stripped.split('|')]
            cells = [c for c in cells if c]  # Remove empty cells from edges
            
            # Skip separator rows
            if cells and not all(re.match(r'^[-:]+$', c) for c in cells):
                table_rows.append(cells)
            
            i += 1
            continue
        elif in_table:
            # End of table
            if table_rows:
                elements.append(('table', table_rows))
            table_rows = []
            in_table = False
            # Don't increment - process this line normally
        
        # Empty line
        if stripped == '':
            i += 1
            continue
        
        # Headers
        if stripped.startswith('# ') and title is None:
            title = stripped[2:].strip()
            elements.append(('title', title))
            i += 1
            continue
        
        if stripped.startswith('## '):
            elements.append(('h2', stripped[3:].strip()))
            i += 1
            continue
        
        if stripped.startswith('### '):
            elements.append(('h3', stripped[4:].strip()))
            i += 1
            continue
        
        if stripped.startswith('#### '):
            elements.append(('h4', stripped[5:].strip()))
            i += 1
            continue
        
        # List items
        if stripped.startswith('- ') or stripped.startswith('* '):
            elements.append(('list', '• ' + stripped[2:]))
            i += 1
            continue
        
        # Numbered list items
        if re.match(r'^\d+\.\s', stripped):
            match = re.match(r'^(\d+)\.\s(.+)$', stripped)
            if match:
                elements.append(('list', f"{match.group(1)}. {match.group(2)}"))
            i += 1
            continue
        
        # Horizontal rule
        if stripped in ['---', '***', '___']:
            elements.append(('hr', None))
            i += 1
            continue
        
        # Regular paragraph
        # Collect continuation lines
        para_lines = [stripped]
        i += 1
        while i < len(lines):
            next_line = lines[i].strip()
            # Stop at empty lines, headers, lists, quotes, tables
            if (next_line == '' or 
                next_line.startswith('#') or 
                next_line.startswith('- ') or
                next_line.startswith('* ') or
                next_line.startswith('>') or
                re.match(r'^\d+\.\s', next_line) or
                '|' in next_line):
                break
            para_lines.append(next_line)
            i += 1
        
        elements.append(('para', ' '.join(para_lines)))
    
    # Handle any remaining quote
    if current_quote:
        elements.append(('quote', '\n'.join(current_quote)))
    
    # Handle any remaining table
    if table_rows:
        elements.append(('table', table_rows))
    
    return elements, title


def build_story(elements, styles):
    """Build the PDF story from parsed elements."""
    story = []
    
    for elem_type, content in elements:
        if elem_type == 'title':
            story.append(Paragraph(convert_inline_formatting(content), styles['DocTitle']))
            story.append(Spacer(1, 12))
        
        elif elem_type == 'h2':
            story.append(Paragraph(convert_inline_formatting(content), styles['SectionHeader']))
        
        elif elem_type == 'h3':
            story.append(Paragraph(convert_inline_formatting(content), styles['SubsectionHeader']))
        
        elif elem_type == 'h4':
            story.append(Paragraph(convert_inline_formatting(content), styles['SubSubsectionHeader']))
        
        elif elem_type == 'para':
            story.append(Paragraph(convert_inline_formatting(content), styles['Body']))
        
        elif elem_type == 'quote':
            # Replace newlines with <br/> for reportlab
            formatted = convert_inline_formatting(content)
            formatted = formatted.replace('\n\n', '<br/><br/>')
            formatted = formatted.replace('\n', '<br/>')
            story.append(Paragraph(formatted, styles['BlockQuote']))
        
        elif elem_type == 'list':
            story.append(Paragraph(convert_inline_formatting(content), styles['ListItem']))
        
        elif elem_type == 'table':
            # Convert table data
            table_data = []
            for row in content:
                table_data.append([convert_inline_formatting(cell) for cell in row])
            
            # Calculate column widths
            num_cols = max(len(row) for row in table_data) if table_data else 1
            col_width = (COLUMN_WIDTH - 12) / num_cols
            
            table = Table(table_data, colWidths=[col_width] * num_cols)
            table.setStyle(TableStyle([
                ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor('#8b0000')),
                ('TEXTCOLOR', (0, 0), (-1, 0), colors.whitesmoke),
                ('ALIGN', (0, 0), (-1, -1), 'LEFT'),
                ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
                ('FONTSIZE', (0, 0), (-1, -1), 8),
                ('BOTTOMPADDING', (0, 0), (-1, 0), 6),
                ('TOPPADDING', (0, 0), (-1, 0), 6),
                ('BACKGROUND', (0, 1), (-1, -1), colors.HexColor('#f9f9f9')),
                ('GRID', (0, 0), (-1, -1), 0.5, colors.HexColor('#cccccc')),
                ('ROWBACKGROUNDS', (0, 1), (-1, -1), 
                 [colors.HexColor('#ffffff'), colors.HexColor('#f5f5f5')]),
                ('VALIGN', (0, 0), (-1, -1), 'TOP'),
            ]))
            story.append(table)
            story.append(Spacer(1, 8))
        
        elif elem_type == 'hr':
            # Simple spacer for horizontal rules
            story.append(Spacer(1, 12))
    
    return story


def create_pdf(input_path, output_path):
    """Create the two-column PDF from markdown."""
    # Read markdown file
    with open(input_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Parse markdown
    elements, title = parse_markdown(content)
    
    # If no title found in content, use filename
    if not any(e[0] == 'title' for e in elements):
        basename = os.path.basename(input_path)
        name = os.path.splitext(basename)[0]
        # Clean up filename for title
        title = name.replace('_', ' ').replace('-', ' - ')
        elements.insert(0, ('title', title))
    
    # Create document
    doc = BaseDocTemplate(
        output_path,
        pagesize=letter,
        leftMargin=MARGIN,
        rightMargin=MARGIN,
        topMargin=MARGIN,
        bottomMargin=MARGIN,
    )
    
    # Create two-column frame template
    frame_left = Frame(
        MARGIN,
        MARGIN,
        COLUMN_WIDTH,
        PAGE_HEIGHT - 2 * MARGIN,
        id='left',
        leftPadding=0,
        rightPadding=6,
        topPadding=0,
        bottomPadding=0,
    )
    
    frame_right = Frame(
        MARGIN + COLUMN_WIDTH + COLUMN_GAP,
        MARGIN,
        COLUMN_WIDTH,
        PAGE_HEIGHT - 2 * MARGIN,
        id='right',
        leftPadding=6,
        rightPadding=0,
        topPadding=0,
        bottomPadding=0,
    )
    
    template = PageTemplate(
        id='TwoColumn',
        frames=[frame_left, frame_right],
    )
    
    doc.addPageTemplates([template])
    
    # Create styles and build story
    styles = create_styles()
    story = build_story(elements, styles)
    
    # Build PDF
    doc.build(story)
    print(f"Created: {output_path}")


def main():
    if len(sys.argv) < 2:
        print("Usage: python md2pdf.py input.md [output.pdf]")
        print("\nConverts markdown session notes to a two-column PDF.")
        sys.exit(1)
    
    input_path = sys.argv[1]
    
    if len(sys.argv) >= 3:
        output_path = sys.argv[2]
    else:
        # Generate output path from input
        basename = os.path.basename(input_path)
        name = os.path.splitext(basename)[0]
        output_path = name + '.pdf'
    
    if not os.path.exists(input_path):
        print(f"Error: File not found: {input_path}")
        sys.exit(1)
    
    create_pdf(input_path, output_path)


if __name__ == '__main__':
    main()