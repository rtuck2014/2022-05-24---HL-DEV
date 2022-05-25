const textArea = document.createElement('textarea')

export function decodeTemplateHtml(html) {
    textArea.innerHTML = html;
    return textArea.value;
}

export function htmlDecode(html) {
    return $("<div/>").html(html).text();
}

export function containsNonLatinCodepoints(string) {
    return /[^\u0000-\u007E]/.test(string);
}

export default {
    decodeTemplateHtml,
    htmlDecode,
    containsNonLatinCodepoints
}
