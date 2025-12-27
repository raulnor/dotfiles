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
    python md2pdf.py input.md [output.pdf] [--left-margin INCHES]

If output is not specified, it will use the input filename with .pdf extension.
"""

import re
import sys
import os
import argparse
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
        spaceAfter=6,
        textColor=colors.HexColor('#2c3e50'),
        alignment=TA_LEFT
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

    # Stat block line (for D&D stat blocks)
    styles.add(ParagraphStyle(
        name='StatLine',
        parent=styles['Normal'],
        fontSize=9,
        leading=11,
        spaceAfter=3,
        alignment=TA_LEFT
    ))

    # Table header cell
    styles.add(ParagraphStyle(
        name='TableHeader',
        parent=styles['Normal'],
        fontSize=9,
        leading=11,
        alignment=TA_CENTER,
        textColor=colors.whitesmoke,
        fontName='Helvetica-Bold'
    ))

    # Table data cell
    styles.add(ParagraphStyle(
        name='TableCell',
        parent=styles['Normal'],
        fontSize=9,
        leading=11,
        alignment=TA_CENTER
    ))

    return styles


def parse_frontmatter(content):
    """Remove YAML frontmatter if present."""
    if content.startswith('---'):
        end = content.find('---', 3)
        if end != -1:
            return content[end + 3:].strip()
    return content

def remove_comments(content):
    content = re.sub(r'<!--.*?-->', '', content, flags=re.DOTALL) # HTML
    content = re.sub(r'%%.*?%%', '', content, flags=re.DOTALL) # Obsidian
    content = re.sub(r':::hidden\n.*?\n:::', '', content, flags=re.DOTALL)
    return content


def convert_inline_formatting(text):
    """Convert markdown inline formatting to reportlab XML tags."""
    # Escape special XML characters first (but not our markdown)
    text = text.replace('&', '&amp;')
    text = text.replace('<', '&lt;')
    text = text.replace('>', '&gt;')

    # Bold + Italic: ***text*** (must be before bold and italic)
    text = re.sub(r'\*\*\*(.+?)\*\*\*', r'<b><i>\1</i></b>', text)
    text = re.sub(r'___(.+?)___', r'<b><i>\1</i></b>', text)

    # Bold: **text** or __text__
    text = re.sub(r'\*\*(.+?)\*\*', r'<b>\1</b>', text)
    text = re.sub(r'__(.+?)__', r'<b>\1</b>', text)

    # Italic: *text* or _text_
    text = re.sub(r'\*(.+?)\*', r'<i>\1</i>', text)
    text = re.sub(r'(?<!\w)_(.+?)_(?!\w)', r'<i>\1</i>', text)

    # Inline code: `text`
    text = re.sub(r'`(.+?)`', r'<font face="Courier" size="8">\1</font>', text)

    # Links: [text](url) - just show the text
    text = re.sub(r'\[([^\]]+)\]\([^)]+\)', r'<font color="#8b0000">\1</font>', text)

    # Wiki links: [[text]] or [[text|display]]
    text = re.sub(r'\[\[([^|\]]+)\|([^\]]+)\]\]', r'<font color="#8b0000">\2</font>', text)
    text = re.sub(r'\[\[([^\]]+)\]\]', r'<font color="#8b0000">\1</font>', text)

    return text


def parse_markdown(content):
    """Parse markdown content into structured elements."""
    content = parse_frontmatter(content)
    content = remove_comments(content)
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
        if '|' in stripped:
            # Table separator row (e.g., |---|---|---|)
            if stripped.startswith('|--') or (in_table and all(re.match(r'^[-:]+$', c.strip()) for c in stripped.split('|') if c.strip())):
                # Skip separator but keep table state active
                i += 1
                continue

            if not in_table:
                in_table = True
                table_rows = []

            # Parse table row
            cells = [c.strip() for c in stripped.split('|')]
            cells = [c for c in cells if c]  # Remove empty cells from edges

            # Add row to table
            if cells:
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

        # Stat block line: **LABEL** content (e.g., **AC** 17, **HP** 110)
        # Match lines that start with **word** followed by space and content
        stat_match = re.match(r'^\*\*([A-Z][A-Za-z\s]*)\*\*\s+(.+)$', stripped)
        if stat_match:
            elements.append(('statline', stripped))
            i += 1
            continue

        # Regular paragraph
        # Collect continuation lines
        para_lines = [stripped]
        i += 1
        while i < len(lines):
            next_line = lines[i].strip()
            # Stop at empty lines, headers, lists, quotes, tables, stat lines
            if (next_line == '' or
                next_line.startswith('#') or
                next_line.startswith('- ') or
                next_line.startswith('* ') or
                next_line.startswith('>') or
                re.match(r'^\d+\.\s', next_line) or
                re.match(r'^\*\*([A-Z][A-Za-z\s]*)\*\*\s+', next_line) or
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


def build_story(elements, styles, column_width=None):
    """Build the PDF story from parsed elements."""
    if column_width is None:
        column_width = COLUMN_WIDTH
    story = []

    i = 0
    while i < len(elements):
        elem_type, content = elements[i]

        if elem_type == 'title':
            story.append(Paragraph(convert_inline_formatting(content), styles['DocTitle']))
            i += 1

        elif elem_type in ['h2', 'h3', 'h4']:
            # Keep heading with following content
            heading_group = []

            if elem_type == 'h2':
                heading_group.append(Paragraph(convert_inline_formatting(content), styles['SectionHeader']))
            elif elem_type == 'h3':
                heading_group.append(Paragraph(convert_inline_formatting(content), styles['SubsectionHeader']))
            elif elem_type == 'h4':
                heading_group.append(Paragraph(convert_inline_formatting(content), styles['SubSubsectionHeader']))

            # Add next few elements to keep together with heading
            j = i + 1
            items_to_keep = 0
            while j < len(elements) and items_to_keep < 3:
                next_type = elements[j][0]
                # Stop at next heading
                if next_type in ['h2', 'h3', 'h4', 'hr']:
                    break
                items_to_keep += 1
                j += 1

            # Add following content to group
            for k in range(i + 1, min(i + 1 + items_to_keep, len(elements))):
                next_elem_type, next_content = elements[k]

                if next_elem_type == 'para':
                    heading_group.append(Paragraph(convert_inline_formatting(next_content), styles['Body']))
                elif next_elem_type == 'list':
                    heading_group.append(Paragraph(convert_inline_formatting(next_content), styles['ListItem']))
                elif next_elem_type == 'quote':
                    formatted = convert_inline_formatting(next_content)
                    formatted = formatted.replace('\n\n', '<br/><br/>')
                    formatted = formatted.replace('\n', '<br/>')
                    heading_group.append(Paragraph(formatted, styles['BlockQuote']))

            story.append(KeepTogether(heading_group))
            i += items_to_keep + 1

        elif elem_type == 'para':
            story.append(Paragraph(convert_inline_formatting(content), styles['Body']))
            i += 1

        elif elem_type == 'quote':
            # Keep blockquotes together
            formatted = convert_inline_formatting(content)
            formatted = formatted.replace('\n\n', '<br/><br/>')
            formatted = formatted.replace('\n', '<br/>')
            story.append(KeepTogether([Paragraph(formatted, styles['BlockQuote'])]))
            i += 1

        elif elem_type == 'list':
            story.append(Paragraph(convert_inline_formatting(content), styles['ListItem']))
            i += 1

        elif elem_type == 'statline':
            story.append(Paragraph(convert_inline_formatting(content), styles['StatLine']))
            i += 1

        elif elem_type == 'table':
            # Keep tables together
            table_data = []
            for row_idx, row in enumerate(content):
                # Wrap each cell in a Paragraph to support rich text formatting
                formatted_row = []
                for cell in row:
                    formatted_text = convert_inline_formatting(cell)
                    # Use appropriate style for header vs data rows
                    if row_idx == 0:
                        # Header row - use TableHeader style
                        cell_para = Paragraph(formatted_text, styles['TableHeader'])
                    else:
                        # Data row - use TableCell style
                        cell_para = Paragraph(formatted_text, styles['TableCell'])
                    formatted_row.append(cell_para)
                table_data.append(formatted_row)

            # Calculate column widths based on content
            num_cols = max(len(row) for row in content) if content else 1

            # Calculate approximate width for each column based on content length
            col_widths = [0] * num_cols
            for row in content:
                for col_idx, cell in enumerate(row):
                    # Estimate width based on character count (rough approximation)
                    # Remove markdown formatting for more accurate width estimation
                    clean_cell = cell
                    clean_cell = re.sub(r'\[([^\]]+)\]\([^)]+\)', r'\1', clean_cell)  # Links
                    clean_cell = re.sub(r'\*\*(.+?)\*\*', r'\1', clean_cell)  # Bold
                    clean_cell = re.sub(r'\*(.+?)\*', r'\1', clean_cell)  # Italic

                    # Estimate width: chars * font_size * char_width_factor
                    estimated_width = len(clean_cell) * 5.5  # Roughly 5.5 points per char for size 9
                    col_widths[col_idx] = max(col_widths[col_idx], estimated_width)

            # Add padding to column widths
            col_widths = [w + 12 for w in col_widths]  # 12 pts padding per column

            # If total width exceeds available space, scale down proportionally
            total_width = sum(col_widths)
            available_width = column_width - 12
            if total_width > available_width:
                scale_factor = available_width / total_width
                col_widths = [w * scale_factor for w in col_widths]

            table = Table(table_data, colWidths=col_widths)
            table.setStyle(TableStyle([
                ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor('#8b0000')),
                ('BACKGROUND', (0, 1), (-1, -1), colors.HexColor('#f9f9f9')),
                ('GRID', (0, 0), (-1, -1), 1, colors.HexColor('#8b0000')),
                ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
                ('BOTTOMPADDING', (0, 0), (-1, -1), 4),
                ('TOPPADDING', (0, 0), (-1, -1), 4),
                ('LEFTPADDING', (0, 0), (-1, -1), 4),
                ('RIGHTPADDING', (0, 0), (-1, -1), 4),
            ]))
            story.append(KeepTogether([table, Spacer(1, 8)]))
            i += 1

        elif elem_type == 'hr':
            # Simple spacer for horizontal rules
            story.append(Spacer(1, 12))
            i += 1

        else:
            i += 1

    return story


def create_pdf(input_path, output_path, left_margin=0.5):
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

    # Calculate margins
    left_margin_size = left_margin * inch
    right_margin_size = MARGIN
    column_width = (PAGE_WIDTH - left_margin_size - right_margin_size - COLUMN_GAP) / 2

    # Create document
    doc = BaseDocTemplate(
        output_path,
        pagesize=letter,
        leftMargin=left_margin_size,
        rightMargin=right_margin_size,
        topMargin=MARGIN,
        bottomMargin=MARGIN,
    )

    # Create two-column frame template
    frame_left = Frame(
        left_margin_size,
        MARGIN,
        column_width,
        PAGE_HEIGHT - 2 * MARGIN,
        id='left',
        leftPadding=0,
        rightPadding=6,
        topPadding=0,
        bottomPadding=0,
    )

    frame_right = Frame(
        left_margin_size + column_width + COLUMN_GAP,
        MARGIN,
        column_width,
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
    story = build_story(elements, styles, column_width)

    # Build PDF
    doc.build(story)
    print(f"Created: {output_path}")


def main():
    parser = argparse.ArgumentParser(
        description='Convert markdown session notes to a two-column PDF.'
    )
    parser.add_argument('input', help='Input markdown file')
    parser.add_argument('output', nargs='?', help='Output PDF file (default: input filename with .pdf extension)')
    parser.add_argument('--left-margin', type=float, default=0.5,
                        help='Left margin size in inches (default: 0.5, recommended: 1.0 for hole punch)')

    args = parser.parse_args()

    input_path = args.input

    if args.output:
        output_path = args.output
    else:
        # Generate output path from input
        basename = os.path.basename(input_path)
        name = os.path.splitext(basename)[0]
        output_path = name + '.pdf'

    if not os.path.exists(input_path):
        print(f"Error: File not found: {input_path}")
        sys.exit(1)

    create_pdf(input_path, output_path, args.left_margin)


if __name__ == '__main__':
    main()