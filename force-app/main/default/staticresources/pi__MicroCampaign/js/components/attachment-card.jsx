import React from 'react'
import { AttachmentDeleteButton } from './attachment-delete-button.jsx';
import { AttachmentProgressBar } from './attachment-progress-bar.jsx';
import {
	AttachmentCardClass,
	AttachmentLinkClass,
	AttachmentLinkTargetClass,
	PiSldsAssetsPath,
} from '../constants'

export const AttachmentLinkRawHtml = (publicUrl) => {
	return `<a class="${AttachmentLinkClass}" href="${publicUrl}" style="cursor:pointer;"></a>`;
};

export const AttachmentCard = ({iconType, title, publicUrl, key, progress = null, deleteCallback = false}) => {
	return (
		<div className={AttachmentCardClass} id={key} style={{
			display: 'block',
			position: 'relative',
			background: 'white',
			border: '1px solid',
			borderColor: '#CCCCCC',
			cursor: 'default',
			width: '458px',
			borderRadius: '4px',
			marginTop: '8px',
		}}>
			<table style={{
				background: '#fafafa',
				position: 'static',
				padding: '5px',
				paddingRight: '3rem',
				tableLayout: 'fixed',
				borderCollapse: 'separate',
				borderSpacing: '2px',
				borderRadius: '4px',
			}}>
				<tbody><tr>
					<td style={{
						lineHeight: 1,
						marginRight: '0.25rem',
						width: '24px',
					}}>
						{renderIcon(iconType, publicUrl)}
					</td>
					<td style={{
						marginBottom: 0,
						width: '100%',
					}}>
						{renderTitleLink(title, publicUrl)}
					</td>
				</tr></tbody>
			</table>
			{deleteCallback ? <AttachmentDeleteButton callback={deleteCallback} /> : null}
			{progress ? <AttachmentProgressBar progress={progress}/> : null}
		</div>
	);

	function renderIcon(iconType, publicUrl) {
		if (publicUrl) {
			return <a className={AttachmentLinkClass} target='_blank' href={publicUrl} style={{
				cursor: 'pointer',
			}}>
				<span className={AttachmentLinkTargetClass} title={`${iconType}`} style={{
					display: 'inline-block',
					borderRadius: '0.25rem',
					width: '24px',
				}}>
					<img aria-hidden='true' src={`${PiSldsAssetsPath}/icons/doctype/${iconType}_20.png`} style={{
						fill: 'white',
						width: 'auto',
						height: '20px',
						lineHeight: 1,
						cursor: 'pointer',
					}}/>
				</span>
			</a>;
		} else {
			return <span className={AttachmentLinkTargetClass} title={`${iconType}`} style={{
				display: 'inline-block',
				borderRadius: '0.25rem',
				width: '24px',
			}}>
				<img aria-hidden='true' src={`${PiSldsAssetsPath}/icons/doctype/${iconType}_20.png`} style={{
					fill: 'white',
					width: 'auto',
					height: '20px',
					lineHeight: 1,
					cursor: 'pointer',
				}}/>
			</span>;
		}
	}

	function renderTitleLink(title, publicUrl) {
		if (publicUrl) {
			return <a className={AttachmentLinkClass} target='_blank' href={publicUrl} style={{
				cursor: 'pointer',
			}}>
				<span className={AttachmentLinkTargetClass} title={title} style={{
					maxWidth: '100%',
					overflow: 'hidden',
					textOverflow: 'ellipsis',
					whiteSpace: 'nowrap',
					marginBottom: 0,
					color: '#0070D2',
					fontSize: '13px',
					fontFamily: "'Salesforce Sans', Arial, sans-serif",
				}}>{title}</span>
			</a>;
		} else {
			return <span className={AttachmentLinkTargetClass} title={title} style={{
				maxWidth: '100%',
				overflow: 'hidden',
				textOverflow: 'ellipsis',
				whiteSpace: 'nowrap',
				marginBottom: 0,
				color: '#0070D2',
				fontSize: '13px',
				fontFamily: "'Salesforce Sans', Arial, sans-serif",
			}}>{title}</span>;
		}
	}
};
